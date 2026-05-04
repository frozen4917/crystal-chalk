module PageResolver
  # Allow only lowercase letters, numbers, hyphens, and underscores as slugs
  VALID_SLUG = /\A[a-z0-9_-]+\z/


  # Resolves a slug to an absolute filepath inside pages_dir.
  # Returns nil if the slug is invalid, the file doesn't exist, or the resolved path escapes pages_dir (path traversal).
  def self.resolve(slug, pages_dir)
    return nil unless valid_slug?(slug) 

    # Anchor pages_dir to the process working directory.
    # Then build the candidate path from slug and assert it stays inside pages_root.
    # This blocks path traversal even if VALID_SLUG somehow passes a bad slug.
    pages_root = File.expand_path(pages_dir, Dir.pwd)
    candidate = File.expand_path("#{slug}.md", pages_root)

    unless candidate.start_with?(pages_root + File::SEPARATOR)
      puts "[Crystal Chalk] Path traversal attempt blocked: '#{candidate}'"
      return nil
    end

    File.file?(candidate) ? candidate : nil
  end

  # Returns true if the slug contains only lowercase letters, numbers, hyphens, and underscores.
  def self.valid_slug?(slug)
    slug.match?(VALID_SLUG)
  end
end