###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

Dir[File.expand_path('../lib/*.rb', __FILE__)].each { |f| require f }

set :source,     'src'
set :css_dir,    'css'
set :js_dir,     'js'
set :images_dir, 'img'

activate :directory_indexes
activate :syntax
activate :quickjump
activate :livereload

activate :search do |config|
  config.resources = data.outline.map{|s| s.url[1..-1] }

  config.fields = {
    id:             { index: false, store: true },
    title:          { boost: 100, store: true, required: true },
    description:    { boost: 90, store: true },
    headers:        { boost: 80, store: false },
    header_details: { index: false, store: true },
    content:        { boost: 50 },
    url:            { index: false, store: true }
  }

  quickjump = self.extensions[:quickjump]

  config.before_index = Proc.new do |to_index, to_store, resource|
    if title = resource.data.title
      if section = data.outline.find{|s| s.title == title }
        [:id, :description].each do |key|
          to_index[key] = to_store[key] = section[key]
        end
      end
    end

    # Would be nice to avoid all this duplicate processing
    page = Nokogiri::HTML(resource.render(layout: false))
    quickjump.process(page)

    to_index[:headers] = page.css('h2, h3, h4').map(&:text).join(' ')
    to_store[:header_details] = page.css('h2').map do |header|
      id = header.css('.dw-nav-token')[0][:id]
      { title: header.text, id: id }
    end
  end
end

activate :s3_redirect do |config|
  aws_creds = Docs::AWS.credentials

  config.bucket = Docs::AWS.bucket
  config.aws_access_key_id = aws_creds[:aws_access_key_id]
  config.aws_secret_access_key = aws_creds[:aws_secret_access_key]
  config.after_build = false # Don't run automatically
end

redirect "/grape", "/getting-set-up"
redirect "/sinatra", "/getting-set-up"
redirect "/billing", "/get-to-know-skylight"
redirect "/feature-walkthrough", "/get-to-know-skylight"
redirect "/filing-bugs", "/contributing"
redirect "/problems/repeated-queries", "/performance-tips"
redirect "/multipe-environments", "/getting-set-up"

#set :markdown_engine, :kramdown
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

helpers Helpers

# Build-specific configuration
configure :build do
  # Checks relative links
  activate :link_check

  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash do |asset_hash|
    # For search
    asset_hash.exts << '.json'
  end

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
