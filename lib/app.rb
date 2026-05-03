require "sinatra/base"
require "sinatra/reloader"
require_relative "config_loader"
require_relative "post_loader"
require_relative "post_cache"
require_relative "page_resolver"
require_relative "rouge_theme"


class App < Sinatra::Base
  # Load config once when the app starts
  @@config = ConfigLoader.load
  RougeTheme.generate(@@config["code_theme"])
  PostCache.warm(@@config)

  # Configure Sinatra settings
  configure do
    set :port, @@config["port"]
    set :bind, "0.0.0.0" # Listen on all interfaces 
    set :views, File.join(__dir__, "..", "views")
    set :public_folder, File.join(__dir__, "..", "public")
    set :show_exceptions, false
  end

  # Enable hot reloading in development only
  configure :development do
    register Sinatra::Reloader
  end

  
  # Index page
  get "/" do
    @posts = PostCache.all
    @site_title = @@config["site_title"]
    @site_url = @@config["site_url"]
    @og_image = @@config["og_image"]
    @theme = @@config["theme"]
    @pages_dir = @@config["pages_dir"]
    @description = @@config["site_description"]

    erb :index # Renders views/index.erb
  end


  # Individual Post
  get "/:slug" do
    slug = params[:slug]

    unless PageResolver.valid_slug?(slug)
      halt 404
    end

    post = PostCache.find(slug)
    # Immediately stop the request and return 404 if file is not found
    halt 404 unless post

    @html = post[:html]
    @title = post[:title]
    @date = post[:date]
    @description = post[:description]
    @draft = post[:draft]
    @reading_time = post[:reading_time]
    @page_title = post[:title]
    @image = post[:image]
    @site_title = @@config["site_title"]
    @site_url = @@config["site_url"]
    @og_image = @@config["og_image"]
    @theme = @@config["theme"]
    @page_type = "article"
    @show_back = true
    
    erb :post # Render the post
  end

  not_found do
    @site_title = @@config["site_title"]    
    @theme = @@config["theme"]
    erb :not_found
  end
end