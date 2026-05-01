require "sinatra/base"
require "sinatra/reloader"
require_relative "config_loader"
require_relative "page_resolver"
require_relative "renderer"


class App < Sinatra::Base
  # Load config once when the app starts
  @@config = ConfigLoader.load

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

  def self.parse_date(raw, filepath: nil)
    return raw if raw.is_a?(Date)
    return Date.parse(raw) if raw.is_a?(String)
  rescue ArgumentError, TypeError => e
    location = filepath ? " in #{filepath}" : ""
    puts "[Crystal Chalk] Warning: invalid date '#{raw}'#{location}"
    nil
  end

  get "/" do
    pages_dir = @@config["pages_dir"]

    # Dir.glob finds all files matching a pattern.
    # Map each file path into a hash of post metadata.
    posts = Dir.glob(File.join(pages_dir, "*.md")).map do |filepath|
      content = File.read(filepath)
      parsed = Renderer.parse(content)
      meta = parsed[:meta]

      date = App.parse_date(meta["date"], filepath: filepath)

      {
        slug: File.basename(filepath, ".md"), # Strip the directory and .md
        title: meta["title"] || "Untitled",
        date: date,
        description: meta["description"] || ""
      }
    end

    # Sort by date, descending. Posts without a date sink to the bottom. 
    posts.sort_by! do |post|
      # .jd returns the julian day number. nil gets mapped to INFINITY
      post[:date] ? -post[:date].jd : Float::INFINITY
    end
    
    @posts = posts
    @site_title = @@config["site_title"]
    @theme = @@config["theme"]

    erb :index # Renders views/index.erb
  end


  get "/:slug" do
    slug = params[:slug] # :slug is the route pattern after / 

    filepath = PageResolver.resolve(slug, @@config["pages_dir"])

    # Immediately stop the request and return 404 if file is not found
    halt 404 unless filepath 

    content = File.read(filepath)
    parsed = Renderer.parse(content)
    word_count = parsed[:html].gsub(/<[^>]+>/, "").split.length

    @meta = parsed[:meta]
    @html = parsed[:html]
    @title = @meta["title"] || slug # Fallback to slug if no title 
    @date = App.parse_date(@meta["date"], filepath: File.join(@@config["pages_dir"], slug))
    @description = @meta["description"] || ""
    @site_title = @@config["site_title"]
    @theme = @@config["theme"]
    @reading_time = "#{[(word_count / 200.0).ceil, 1].max} min read"
    
    erb :post # Render the post
  end

  not_found do
    @site_title = @@config["site_title"]    
    @theme = @@config["theme"]
    erb :not_found
  end
end