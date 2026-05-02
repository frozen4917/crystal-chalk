module PageResolver
  
  # Allow only lowercase letters, numbers, hyphens, and underscores as slugs
  VALID_SLUG = /\A[a-z0-9_-]+\z/

  def self.resolve(slug, pages_dir)

    # Reject invalid slugs or attempts to access other files.
    unless slug.match?(VALID_SLUG)
      puts "[Crystal Chalk] Rejected slug: '#{slug}'" unless slug == "favicon.ico"
      return nil
    end

    # Build the absolute path of pages directory and anchor it to the project root.
    pages_root = File.expand_path(pages_dir, Dir.pwd)

    # Build the candidate file path from the slug
    candidate = File.expand_path("#{slug}.md", pages_root)

    # Assert the resolved path actually lives in pages_root directory
    unless candidate.start_with?(pages_root + File::SEPARATOR)
      puts "[Crystal Chalk] Path traversal attempt blocked: '#{candidate}'"
      return nil
    end

    return candidate if File.file?(candidate)

    nil # Nothing found
  end

  def self.valid_slug?(slug)
    slug.match?(VALID_SLUG)
  end
end