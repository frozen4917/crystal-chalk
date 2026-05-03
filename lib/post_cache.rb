require "listen"
require_relative "post_loader"

module PostCache 
  @cache = {}

  # Mutex prevents race conditions by preventing read and write to a cache at the same time
  @mutex = Mutex.new

  def self.warm(config)
    # Load posts from config
    @config = config 
    pages_dir = config["pages_dir"]

    # Load everything, including drafts
    posts = PostLoader.all_with_drafts(config)

    @mutex.synchronize do
      # Build a hash from posts array 
      @cache = posts.each_with_object({}) do |post, hash|
        hash[post[:slug]] = post
      end
    end

    puts "[Crystal Chalk] Cached #{@cache.size} post(s)."

    if ENV['APP_ENV'] != 'production'
      start_watcher(pages_dir)
    else
      puts "[Crystal Chalk] File watcher disabled in production."
    end
  end

  def self.all
    # Return all non-drafts softed by date descending.
    @mutex.synchronize do 
      @cache.values
    end.reject { |p| p[:draft] }
      .sort_by { |p| p[:date] ? -p[:date].jd : Float::INFINITY }
  end

  def self.find(slug)
    # Returns a post
    @mutex.synchronize { @cache[slug] }
  end

  private 

  def self.start_watcher(pages_dir)
    listener = Listen.to(pages_dir, only: /\.md$/) do |modified, added, removed|
      # Listen yields three arrays: changed files, new files, deleted files. Each is an array of absolute file paths.
      modified.each { |path| reload(path, :modified) }
      added.each { |path| reload(path, :added) }
      removed.each { |path| remove(path) }
    end

    # Run the watcher in a background thread.
    listener.start

    puts "[Crystal Chalk] Watching #{pages_dir}/ for changes."
  end

  def self.reload(filepath, reason)
    slug = File.basename(filepath, ".md")
    post = PostLoader.build(filepath)

    if post
      @mutex.synchronize { @cache[slug] = post }
      puts "[Crystal Chalk] #{reason == :added ? "Added" : "Reloaded"}: #{File.basename(filepath)}"
    end
  end

  def self.remove(filepath)
    slug = File.basename(filepath, ".md")
    @mutex.synchronize { @cache.delete(slug) }
    puts "[Crystal Chalk] Removed: #{File.basename(filepath)}"
  end

end