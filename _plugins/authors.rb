#
# Heavealy inspired from https://github.com/jguyomard/jekyll-paginate-categories
#

module Jekyll
  module Paginate
    module Authors

      class Page < Jekyll::Page
        def initialize(site, base, author)
          layout = site.config['paginate_author_layout'] || 'author.html'
          layouts_base = site.config['layouts_dir'] || '_layouts'
          super(site, base, layouts_base, layout)
          process('index.html')
          
          self.data['prefix'] = site.config['author_title_prefix'] || 'Rédacteur: '
          self.data['title'] = author
          self.data['type'] = 'Articles'
        end
      end

      class Index < Jekyll::Page
        def initialize(site, base, posts_by_author)
          @site = site
          @base = base
          @dir = site.config['author_dir'] || 'authors'
          @name = 'index.html'
          
          layouts_base = site.config['layouts_dir'] || '_layouts'
          layout = site.config['author_index_layout'] || 'authors-index.html'

          self.process(@name)
          self.read_yaml(File.join(base, layouts_base), layout)

          process('index.html')
          
          self.data['authors'] = posts_by_author.keys
          self.data['posts_by_author'] = posts_by_author
        end
      end

      class AuthorPagination < Generator
        safe true
        
        def generate(site)
          if site.config['paginate_author_basepath']
            posts_by_author = get_posts_by_author(site)
            
            site.pages << Index.new(site, site.source, posts_by_author)
            
            posts_by_author.each do |author, posts|
              paginate_author(site, author, posts)
            end
          end
        end

        def get_posts_by_author(site)
          posts_by_author = {}

          for post in site.posts.docs.reverse
            if post.data['authors']
              for author in post.data['authors']
                if !posts_by_author[author]
                  posts_by_author[author] = []
                end
                posts_by_author[author].push(post)
              end
            end

            if post.data['author']
              if !posts_by_author[post.data['author']]
                posts_by_author[post.data['author']] = []
              end
              posts_by_author[post.data['author']].push(post)
            end
          end

          posts_by_author.each do |author, posts|
            posts.uniq! { |p| p.id }
          end

          posts_by_author = posts_by_author.sort_by { |author, posts| author }.to_h
          posts_by_author = posts_by_author.sort_by { |author, posts| -posts.size }.to_h

          return posts_by_author
        end
        
        def paginate_author(site, author, all_posts)
          # Author base path
          author_path = site.config['paginate_author_basepath'] || '/authors/:name/'
          author_path = author_path.sub(':name', Utils.slugify(author, :mode => 'ascii'))
          
          # Count pages
          nb_pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)

          # Create pages
          (1..nb_pages).each do |current_num_page|
            # Split posts into pages
            pager = Pager.new(site, current_num_page, all_posts, nb_pages)
            pager.update_paginate_paths(site, author_path)

            # Create new page, based on author layout
            newpage = Page.new(site, site.source, author)
            newpage.pager = pager
            newpage.dir = Pager.paginate_path_author(site, current_num_page, author_path)
            site.pages << newpage
          end
        end
      end

      class Pager < Jekyll::Paginate::Pager
        def update_paginate_paths(site, author_path)
          if @page > 1
            @previous_page_path = author_path.sub(/(\/)+$/,'') + @previous_page_path
          end
          if @page < @total_pages
            @next_page_path = author_path.sub(/(\/)+$/,'') + @next_page_path
          end
        end
        
        def self.paginate_path_author(site, num_page, author_path, paginate_path = site.config['paginate_path'])
          return nil if num_page.nil?
          return author_path if num_page <= 1
          format = author_path.sub(/(\/)+$/,'') + paginate_path
          format = format.sub(':num', num_page.to_s)
          ensure_leading_slash(format)
        end
      end

    end
  end
end