require "date"
require_relative "renderer"
require_relative "utils"

module Postloader
  
  def self.all(config)
    pages_dir = config["pages_dir"]

    Dir.glob(File.join(pages_dir, "*.md")).map do |filepath|
      build_post(filepath)
    end.sort_by do |post|
      # Compare Date objects in descending order. nil is mapped to INFINITY and sinks to the bottom.
      post[:date] ? -post[:date].jd : Float::INFINITY
    end
  end

  # Returns the parsed post hash for a single slug, or nil if not found. Page resolver handles the security checks, so we just read and parse here.
  def self.find(slug, config)
    require_relative "page_resolver"
    filepath = PageResolver.resolve(slug, config["pages_dir"])

    # Early exit if filepath not found
    return nil unless filepath

    build_post(filepath)
  end

  private 

  def self.build_post(filepath)
    content = File.read(filepath)
    parsed = Renderer.parse(content)
    meta = parsed[:meta]

    {
      slug: File.basename(filepath, ".md"),
      title: meta["title"] || "Untitled",
      date: Utils.parse_date(meta["date"], filepath: File.basename(filepath)),
      description: meta["description"] || "",
      html: parsed[:html],
      reading_time: Utils.reading_time(parsed[:html])
    }

  end

end