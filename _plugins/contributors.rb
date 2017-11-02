#
# Heavealy inspired from https://github.com/jguyomard/jekyll-paginate-categories
#

module Jekyll
  module Paginate
    module Contributors

      class Page < Jekyll::Page
        def initialize(site, base, contributor)
          layout = site.config['paginate_contributor_layout'] || 'contributor.html'
          layouts_base = site.config['layouts_dir'] || '_layouts'
          super(site, base, layouts_base, layout)
          process('index.html')
          
          title_prefix = site.config['contributor_title_prefix'] || 'Correcteur: '
          self.data['prefix'] = site.config['contributor_title_prefix'] || 'Correcteur: '
          self.data['title'] = contributor
          self.data['type'] = 'Corrections'
        end
      end

      class Index < Jekyll::Page
        def initialize(site, base, posts_by_contributor)
          @site = site
          @base = base
          @dir = site.config['contributor_dir'] || 'contributors'
          @name = 'index.html'
          
          layouts_base = site.config['layouts_dir'] || '_layouts'
          layout = site.config['contributor_index_layout'] || 'contributors-index.html'

          self.process(@name)
          self.read_yaml(File.join(base, layouts_base), layout)

          process('index.html')
          
          self.data['contributors'] = posts_by_contributor.keys
          self.data['posts_by_contributor'] = posts_by_contributor
        end
      end

      class ContributorPagination < Generator
        safe true
        
        def generate(site)
          if site.config['paginate_contributor_basepath']
            posts_by_contributor = get_posts_by_contributor(site)
            
            site.pages << Index.new(site, site.source, posts_by_contributor)
            
            posts_by_contributor.each do |contributor, posts|
              paginate_contributor(site, contributor, posts)
            end
          end
        end

        def get_posts_by_contributor(site)
          posts_by_contributor = {}

          for post in site.posts.docs.reverse
            if post.data['contributors']
              for contributor in post.data['contributors']
                if !posts_by_contributor[contributor]
                  posts_by_contributor[contributor] = []
                end
                posts_by_contributor[contributor].push(post)
              end
            end

            if post.data['contributor']
              if !posts_by_contributor[post.data['contributor']]
                posts_by_contributor[post.data['contributor']] = []
              end
              posts_by_contributor[post.data['contributor']].push(post)
            end
          end

          posts_by_contributor.each do |contributor, posts|
            posts.uniq! { |p| p.id }
          end

          posts_by_contributor = posts_by_contributor.sort_by { |contributor, posts| contributor }.to_h
          posts_by_contributor = posts_by_contributor.sort_by { |contributor, posts| -posts.size }.to_h

          return posts_by_contributor
        end
        
        def paginate_contributor(site, contributor, all_posts)
          # Author base path
          contributor_path = site.config['paginate_contributor_basepath'] || '/contributors/:name/'
          contributor_path = contributor_path.sub(':name', Utils.slugify(contributor, :mode => 'ascii'))
          
          # Count pages
          nb_pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)

          # Create pages
          (1..nb_pages).each do |current_num_page|
            # Split posts into pages
            pager = Pager.new(site, current_num_page, all_posts, nb_pages)
            pager.update_paginate_paths(site, contributor_path)

            # Create new page, based on contributor layout
            newpage = Page.new(site, site.source, contributor)
            newpage.pager = pager
            newpage.dir = Pager.paginate_path_contributor(site, current_num_page, contributor_path)
            site.pages << newpage
          end
        end
      end

      class Pager < Jekyll::Paginate::Pager
        def update_paginate_paths(site, contributor_path)
          if @page > 1
            @previous_page_path = contributor_path.sub(/(\/)+$/,'') + @previous_page_path
          end
          if @page < @total_pages
            @next_page_path = contributor_path.sub(/(\/)+$/,'') + @next_page_path
          end
        end
        
        def self.paginate_path_contributor(site, num_page, contributor_path, paginate_path = site.config['paginate_path'])
          return nil if num_page.nil?
          return contributor_path if num_page <= 1
          format = contributor_path.sub(/(\/)+$/,'') + paginate_path
          format = format.sub(':num', num_page.to_s)
          ensure_leading_slash(format)
        end
      end

    end
  end
end