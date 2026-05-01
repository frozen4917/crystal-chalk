require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

module Renderer 
  # Custom HTML Renderer extended with Rouge's plugin for syntax highlighting

  class HTMLWithRouge < Redcarpet::Render::HTML 
    include Rouge::Plugins::Redcarpet

    
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
    meta = {}
    body = content

    if (match = FRONTMATTER_PATTERN.match(content))
      begin
        require "psych"
        meta = Psych.safe_load(match[1], permitted_classes: [Date]) || {}
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