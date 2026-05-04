require "sinatra/base"
require "sinatra/reloader"
require "uri"
require_relative "config_loader"
require_relative "post_loader"
require_relative "post_cache"
require_relative "page_resolver"
require_relative "rouge_theme"


class App < Sinatra::Base
  # Boot sequence: config must load first since everything else depends on it.
  # RougeTheme and PostCache are initialised at class load time so they're ready before the first request arrives.
  @@config = ConfigLoader.load
  RougeTheme.generate(@@config["code_theme"])
  PostCache.warm(@@config)

  # Derive the host whitelist from site_url + extra_hosts.
  # Used by Sinatra's host_authorization in production to block DNS rebinding.
  @@allowed_hosts = begin
    primary_host = URI.parse(@@config["site_url"]).host if @@config["site_url"] && !@@config["site_url"].empty?
    extra_hosts  = @@config["extra_hosts"] || []
    ([primary_host] + extra_hosts).compact.reject(&:empty?)
  rescue URI::InvalidURIError
    puts "[Crystal Chalk] Warning: invalid site_url in settings.yml. Host authorisation will not be enforced."
    []
  end

  # --- SINATRA CONFIGURATION ---

  configure do
    set :port,            @@config["port"]
    set :bind,            "0.0.0.0"
    set :views,           File.join(__dir__, "..", "views")
    set :public_folder,   File.join(__dir__, "..", "public")
    set :show_exceptions, false
  end

  configure :development do
    register Sinatra::Reloader
    # Disable host authorisation and Rack::Protection in development so localhost, ngrok, and other tunnel tools work without configuration
    set :protection, false
    set :host_authorization, { permitted_hosts: [] }
  end

  configure :production do
    set :logging, false
    # If no hosts were derived (empty site_url), authorisation is left open rather than breaking the server.
    if @@allowed_hosts.empty?
      set :host_authorization, { permitted_hosts: [] }
    else
      # Always allow loopback so internal health checks and reverse proxies work.
      set :host_authorization, { permitted_hosts: @@allowed_hosts + ["localhost", "127.0.0.1"] }
    end
  end

  # --- ROUTES ---
  
  # Index: lists all published posts sorted newest first.
  get "/" do
    @posts        = PostCache.all
    @site_title   = @@config["site_title"]
    @site_url     = @@config["site_url"]
    @og_image     = @@config["og_image"]
    @theme        = @@config["theme"]
    @pages_dir    = @@config["pages_dir"]
    @description  = @@config["site_description"]

    erb :index # Renders views/index.erb
  end

  # Post: serves a single post by slug.
  # Halts with 404 for invalid slugs or slugs that don't match a file
  get "/:slug" do
    slug = params[:slug]

    unless PageResolver.valid_slug?(slug)
      halt 404
    end

    post = PostCache.find(slug)
    # Immediately stop the request and return 404 if file is not found
    halt 404 unless post

    # Populate all instance variables the post template needs
    @html         = post[:html]
    @title        = post[:title]
    @date         = post[:date]
    @description  = post[:description]
    @draft        = post[:draft]
    @reading_time = post[:reading_time]
    @page_title   = post[:title]
    @image        = post[:image]
    @site_title   = @@config["site_title"]
    @site_url     = @@config["site_url"]
    @og_image     = @@config["og_image"]
    @theme        = @@config["theme"]
    @page_type    = "article"
    @show_back    = true
    
    erb :post # Render the post
  end

  # Renders the not_found view with minimal context for all 404s
  not_found do
    @site_title = @@config["site_title"]    
    @theme      = @@config["theme"]
    erb :not_found
  end
end