module Jekyll
    class CategoryPage < Page
      def initialize(site, base, dir, category)
        @site = site
        @base = base
        @dir = dir
        @name = 'index.html'
        layouts_base = site.config['layouts_dir'] || '_layouts'
  
        self.process(@name)
        self.read_yaml(File.join(base, layouts_base), 'category.html')
        self.data['category'] = category
  
        category_title_prefix = site.config['category_title_prefix'] || 'Category: '
        self.data['title'] = "#{category_title_prefix}#{category}"
        self.data['posts'] = site.posts.docs.select do |post|
            post.data['categories'].include?(category) or post.data['category'] == category
        end
      end
    end
  
    class CategoryPageGenerator < Generator
      safe true
  
      def generate(site)
        if site.layouts.key? 'category'
          dir = site.config['category_dir'] || 'categories'
          site.categories.each_key do |category|
            site.pages << CategoryPage.new(site, site.source, File.join(dir, Utils.slugify(category, :mode => 'ascii')), category)
          end
        end
      end
    end
  end