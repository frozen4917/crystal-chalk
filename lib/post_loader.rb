require "date"
require_relative "renderer"
require_relative "utils"

module PostLoader
  # Resolves a slug to a filepath via PageResolver and builds the post hash.
  # Returns nil if slug doesn't resolve to a valid file.
  def self.find(slug, config)
    require_relative "page_resolver"
    filepath = PageResolver.resolve(slug, config["pages_dir"])

    # Early exit if filepath not found
    return nil unless filepath

    build(filepath)
  end

  # Loads all posts including drafts. Used by PostCache on startup and file watch events.
  def self.all_with_drafts(config)
    pages_dir = config["pages_dir"]
    Dir.glob(File.join(pages_dir, "*.md"))
      .map { |filepath| build(filepath) }
      .compact # Remove nil values
  end

  # Reads and parses a single .md file into a post hash
  # Returns nil if file is missing or raises on read/parse
  def self.build(filepath)
    return nil unless File.file?(filepath)

    begin 
      content = File.read(filepath)
      parsed = Renderer.parse(content)
      meta = parsed[:meta]

      {
        slug:         File.basename(filepath, ".md"),
        title:        meta["title"] || "Untitled",
        date:         Utils.parse_date(meta["date"], 
        filepath:     File.basename(filepath)),
        description:  meta["description"] || "",
        image:        meta["image"] || nil,
        draft:        meta["draft"] == true,
        html:         parsed[:html],
        reading_time: Utils.reading_time(parsed[:html])
      }
    rescue => e
      puts "[Crystal Chalk] Error reading #{File.basename(filepath)}: #{e.message}"
      nil
    end
  end
end