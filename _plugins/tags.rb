#
# Heavealy inspired from https://github.com/jguyomard/jekyll-paginate-categories
#

module Jekyll
  module Paginate
    module Tags

      class Page < Jekyll::Page
        # Initialize a new Tag Page
        def initialize(site, base, tag)
          layout = site.config['paginate_tag_layout'] || 'tag.html'
          layouts_base = site.config['layouts_dir'] || '_layouts'
          super(site, base, layouts_base, layout)
          process('index.html')
          
          tag_title_prefix = site.config['tag_title_prefix'] || 'Tag: '
          self.data['title'] = "#{tag_title_prefix}#{tag}"
        end
      end

      class Index < Jekyll::Page
        # Initialize a new Tag Page
        def initialize(site, base, posts_by_tag)
          @site = site
          @base = base
          @dir = site.config['tag_dir'] || 'tags'
          @name = 'index.html'
          
          layouts_base = site.config['layouts_dir'] || '_layouts'
          layout = site.config['tag_index_layout'] || 'tags-index.html'

          self.process(@name)
          self.read_yaml(File.join(base, layouts_base), layout)

          process('index.html')
          
          self.data['tags'] = posts_by_tag.keys
          self.data['posts_by_tag'] = posts_by_tag
        end
      end
      
      # Per-tag pagination.
      # Based on jekyll-paginate.
      # 
      # paginate_tag_basepath: category base path - eg, /tags/:name/
      # paginate_path: will be concatenated with paginate_tag - eg /page/:num/
      # paginate_tag_layout: The layout name of the category layout (default: categories.html)
      class TagPagination < Generator
        safe true

        # Generate paginated pages if necessary.
        #
        # site - The Site.
        #
        # Returns nothing.
        def generate(site)
          if site.config['paginate_category_basepath']
            posts_by_tag = get_posts_by_tag(site)
            
            site.pages << Index.new(site, site.source, posts_by_tag)
            
            posts_by_tag.each do |tag, posts|
              paginate_tag(site, tag)
            end
          end
        end

        def get_posts_by_tag(site)
          posts_by_tag = {}

          for post in site.posts.docs.reverse
            if post.data['tags']
              for tag in post.data['tags']
                if !posts_by_tag[tag]
                  posts_by_tag[tag] = []
                end
                posts_by_tag[tag].push(post)
              end
            end

            if post.data['tag']
              if !posts_by_tag[post.data['tag']]
                posts_by_tag[post.data['tag']] = []
              end
              posts_by_tag[post.data['tag']].push(post)
            end
          end

          posts_by_tag.each do |tag, posts|
            posts.uniq! { |p| p.id }
          end

          posts_by_tag = posts_by_tag.sort_by { |tag, posts| tag }.to_h
          posts_by_tag = posts_by_tag.sort_by { |tag, posts| -posts.size }.to_h

          return posts_by_tag
        end

        # Do the blog's posts pagination per tag. Renders the index.html file into paginated 
        # directories (see paginate_tag_basepath and paginate_path config) for these categories, 
        # e.g.: /tags/my-tag/page2/index.html, /tags/my-tag/page3/index.html, etc.
        #
        # site     - The Site.
        # tag - The tag to paginate.
        #
        # Returns nothing.
        def paginate_tag(site, tag)
          # Retrieve posts from that specific tag.
          all_posts = site.posts.docs.select do |post|
            post.data['tags'].include?(tag) or post.data['tag'] == tag
          end

          # Tag base path
          tag_path = site.config['paginate_tag_basepath'] || '/tags/:name/'
          tag_path = tag_path.sub(':name', Utils.slugify(tag, :mode => 'ascii'))
          
          # Count pages
          nb_pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)

          # Create pages
          (1..nb_pages).each do |current_num_page|
            # Split posts into pages
            pager = Pager.new(site, current_num_page, all_posts, nb_pages)
            pager.update_paginate_paths(site, tag_path)

            # Create new page, based on tag layout
            newpage = Page.new(site, site.source, tag)
            newpage.pager = pager
            newpage.dir = Pager.paginate_path_tag(site, current_num_page, tag_path)
            site.pages << newpage
          end
        end
      end

      class Pager < Jekyll::Paginate::Pager
        # Update paginator.previous_page_path and next_page_path to add tag path
        #
        # site            - the Jekyll::Site object
        # tag_path   - tag path, eg /tags/web/
        #
        # Returns nothing.
        def update_paginate_paths(site, tag_path)
          if @page > 1
            @previous_page_path = tag_path.sub(/(\/)+$/,'') + @previous_page_path
          end
          if @page < @total_pages
            @next_page_path = tag_path.sub(/(\/)+$/,'') + @next_page_path
          end
        end

        # Static: Return the pagination path of the page
        #
        # site     - the Jekyll::Site object
        # num_page - the pagination page number
        # paginate_path - the explicit paginate path, if provided
        #
        # Returns the pagination path as a string
        def self.paginate_path_tag(site, num_page, tag_path, paginate_path = site.config['paginate_path'])
          return nil if num_page.nil?
          return tag_path if num_page <= 1
          format = tag_path.sub(/(\/)+$/,'') + paginate_path
          format = format.sub(':num', num_page.to_s)
          ensure_leading_slash(format)
        end
      end

    end
  end
end