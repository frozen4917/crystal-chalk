require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

module Renderer 
  # Custom HTML Renderer extended with Rouge's plugin for syntax highlighting

  class HTMLWithRouge < Redcarpet::Render::HTML 
    include Rouge::Plugins::Redcarpet

    def image(link, title, alt_text)
      # Check for size modifier in alt text, e.g. "Alt|small"
      size_class = nil
      clean_alt = alt_text.to_s 

      if clean_alt.include?("|")
        parts = clean_alt.split("|")
        clean_alt = parts[0].strip 
        modifier = parts[1].strip.downcase
        size_class = "img-#{modifier}" if %w[small medium large].include?(modifier)
      end

      css_class = size_class ? " class=\"#{size_class}\"": ""
      title_attr = title ? " title=\"#{title}}\"" : ""

      "<img src=\"#{link}\"#{title_attr} alt=\"#{clean_alt}\"#{css_class}>"
    end
  end

  RENDERER = Redcarpet::Markdown.new(
    HTMLWithRouge.new(
      # Security options:
      filter_html: true,    # Strips raw HTML tags in .md file
      no_styles: true,      # Strips <style> tags
      safe_links_only: true # Only allow http, https, mailto links.
    ),
    # Markdown feature flags
    fenced_code_blocks: true, # ```js, ```ruby style code blocks
    autolink: true,           # Bare URLs become clickable links
    strikethrough: true,      # ~~striked text~~
    tables: true,             # MD Tables
    no_intra_emphasis: true,
    lax_spacing: true   # allows lists without a preceding blank line
  ).freeze

  # Frontmatter is the optional YAML block at the top of a .md file between two --- delimiters. Like this:
  #   ---
  #   title: My Post
  #   date: 2026-04-30
  #   description: A short summary
  #   ---
  # This regex captures everything between the two --- lines.
  FRONTMATTER_PATTERN = /\A---\s*\n(.*?)\n---\s*\n/m

  def self.parse(content)
    # Normalize Windows (\r\n) and old Mac (\r) line endings to Unix (\n). Regex expects this.
    content = content.gsub("\r\n", "\n").gsub("\r", "\n")

    meta = {}
    body = content

    if (match = FRONTMATTER_PATTERN.match(content))
      begin
        require "psych"
        meta = Psych.safe_load(match[1], permitted_classes: [Date, Time]) || {}
        # match[1] is the captured YAML string inside '---' block
      rescue Psych::Exception => e
        # Malformed YAML. Warn but don't crash. Post still renders, just without metadata.
        puts "[Crystal Chalk] Warning: bad frontmatter detected - #{e.message}"
        meta = {}
      end

      # Remove the frontmatter block from content before rendering. 
      # match[0] is the full matched string including the --- delimiters
      body = content.sub(match[0], "")
    end

    {
      meta: meta,
      html: RENDERER.render(body)
    }
  end
end