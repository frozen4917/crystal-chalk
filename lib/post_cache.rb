require "listen"
require_relative "post_loader"

module PostCache 
  @cache = {}
  # Mutex prevents concurrent reads and writes to @cache from the watcher thread.
  @mutex = Mutex.new

  # Loads all posts (including drafts) into @cache and starts the file watcher in development.
  def self.warm(config)
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

  # Returns all non-draft posts sorted newest first. Undated posts sink to the bottom.
  def self.all
    @mutex.synchronize do 
      @cache.values
    end.reject { |p| p[:draft] }
      .sort_by { |p| p[:date] ? -p[:date].jd : Float::INFINITY }
  end

  # Returns a post from cache
  def self.find(slug)
    @mutex.synchronize { @cache[slug] }
  end

  private 

  # Watches pages_dir for .md changes and hot-reloads the cache without a server restart.
  def self.start_watcher(pages_dir)
    listener = Listen.to(pages_dir, only: /\.md$/) do |modified, added, removed|
      modified.each { |path| reload(path, :modified) }
      added.each    { |path| reload(path, :added) }
      removed.each  { |path| remove(path) }
    end

    # Run the watcher in a background thread.
    listener.start
    puts "[Crystal Chalk] Watching #{pages_dir}/ for changes."
  end

  # Re-parses a file and updates its entry in the cache
  def self.reload(filepath, reason)
    slug = File.basename(filepath, ".md")
    post = PostLoader.build(filepath)

    if post
      @mutex.synchronize { @cache[slug] = post }
      puts "[Crystal Chalk] #{reason == :added ? "Added" : "Reloaded"}: #{File.basename(filepath)}"
    end
  end

  # Removes a deleted file's entry from the cache.
  def self.remove(filepath)
    slug = File.basename(filepath, ".md")
    @mutex.synchronize { @cache.delete(slug) }
    puts "[Crystal Chalk] Removed: #{File.basename(filepath)}"
  end

end