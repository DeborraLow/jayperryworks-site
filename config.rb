# CSV libs - http://www.ict4g.net/adolfo/notes/2015/05/30/csv_data_in_middleman.html
# require 'lib/csv_helpers.rb'
# activate :csv_helpers

###
# Page options, layouts, aliases and proxies
###

# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# General configuration
###

config[:images_dir] = 'assets/images'
config[:css_dir] = 'stylesheets'
config[:js_dir] = 'javascripts'

# ignore css and js, b/c we're handling with external pipeline
ignore 'assets/stylesheets/*'
ignore 'assets/javascripts/*'

activate :external_pipeline,
    name: :npm,
    command: build? ? 'yarn run build' : 'yarn run start',
    source: ".tmp/dist",
    latency: 1

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# run the blog extension
activate :blog do |blog|
    blog.name = "work"
    blog.prefix = "work"
    blog.sources = "{year}/{title}.html"
    blog.permalink = "{category}/{year}/{title}.html"
    blog.layout = "print"
end

config[:blog_summary_separator] = /EXCERPT/

activate :blog do |blog|
    blog.name = "writing"
    blog.prefix = "writing"
    blog.sources = "{year}/{month}-{day}-{title}.html"
    blog.permalink = "{year}/{month}/{title}.html"
    blog.taglink = "tags/{tag}.html"
    blog.summary_length = nil
    blog.summary_separator = config[:blog_summary_separator]
    blog.layout = "blog_post"
    blog.paginate = true
    blog.per_page = 20
end

activate :directory_indexes
page "404.html", :directory_index => false

set :markdown_engine, :kramdown

# Use relative URLs
# activate :relative_assets

# Enable cache buster
# activate :asset_hash

# autoprefix CSS
# activate :autoprefixer do |config|
#     config.browsers = ['last 2 versions', 'Explorer >= 8']
# end

activate :google_analytics do |ga|
    ga.tracking_id = 'UA-51213824-1' # Replace with your property ID.
end

# Reload the browser automatically whenever files change
configure :development do
    activate :livereload
end


###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do

  # check to see if a highlight color is one of the defaults listed in colors.yml
  def highlight(color)
    if data.colors.include? color
      return data.colors[color.to_s]
    else
      return color
    end
  end

  # grab a yml file from an arbitrary location and read it
  # -> used for storing data outside of the 'data' folder
  # -> http://stackoverflow.com/questions/13310488/how-can-i-read-a-yaml-file
  # def getYML(file) {
  #   return YAML.load_file(file)
  # }

  # "Component" decorator for partial function
  # -> just used to point automatically to "components" dir so you don't have to type the full path
  def component(name, opts = {}, &block)
      partial("components/#{name}", opts, &block)
  end

  # build an array of the posts from a given blog
  # STRING
  def get_posts(name)
    posts = []
    blog(name).articles.each do |post|
      posts.push(post)
    end
    return posts
  end

  def find_post_index(post, blog_name = "writing")
    posts = get_posts(blog_name)
    if posts.include?(post)
      return posts.index(post)
    else
      return false
    end
  end

  def next_post(post, blog_name = "writing")
    # find next post in TOC
    if find_post_index(post, blog_name) < (get_posts.length - 1)
      return get_posts[find_post_index(post, blog_name) + 1]
    else
      return false
    end
  end

  def prev_post(post, blog_name = "writing")
    # find previous post in TOC
    if find_post_index(post, blog_name) > 0
      return get_posts[find_post_index(post, blog_name) - 1]
    else
      return false
    end
  end

  def current_page?(url)
    if current_page.url == url then
      return true
    else
      return false
    end
  end
end

set :url_root, 'http://jayperryworks.com'
# activate :search_engine_sitemap

# Use relative links all the time - helps catch url bugs before deployment
set :relative_links, true

# Build-specific configuration
configure :build do

    # Enable cache buster
    # activate :asset_hash

    activate :minify_html

    # For example, change the Compass output style for deployment
    # activate :minify_css

    # "Ignore" JS so webpack has full control.
    # ignore { |path| path =~ /\/(.*)\.js$/ && $1 != 'all' }

    # Minify Javascript on build
    # activate :minify_javascript

    # Compress/optimize images
    # -> svg optimization is handled by svgo
    # activate :imageoptim do |options|
    #     options.image_extensions = %w(.png .jpg .gif .svg)
    # end

    # Or use a different image path
    # set :http_prefix, "/Content/images/"
end

# Copy the server config files in /public after build
# Cheers to Makzan for posting this. https://www.makzan.net/2015/09/configure-files-to-copy-without-middleman-building-process/
after_build do |builder|
  FileUtils.cp_r 'public/.', 'build'
end
