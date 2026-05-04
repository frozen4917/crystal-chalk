require "date"

module Utils 
  # Strips leading #, validates 3 or 6 hex chars, and returns bare hex srting or nil.
  def self.normalize_color(value)
    hex = value.to_s.strip.delete_prefix("#")

    # Must be either 3 or 6 characters in length AND contain only A-F, a-f, 0-9
    if hex.match?(/\A[0-9a-fA-F]{3}\z/) || hex.match?(/\A[0-9a-fA-F]{6}\z/)
      hex
    else
      puts "[Crystal Chalk] Warning: '#{value}' is not a valid hex color. Using default value."
      nil
    end
  end
    
  # Accepts a Date, Time, or String and retusn a Date. Returns nil on failure.
  def self.parse_date(raw, filepath: nil)
    return nil if raw.nil?
    # If it is a Date object, return it
    return raw if raw.is_a?(Date)

    # If is it a Time object, return the date part
    return raw.to_date if raw.is_a?(Time)

    # If it is a String object, parse it
    return Date.parse(raw) if raw.is_a?(String)

  rescue ArgumentError, TypeError
    location = filepath ? " in #{filepath}" : ""
    puts "[Crystal Chalk] Warning: invalid date '#{raw}'#{location}"
    nil
  end

  # Return reading time based on avergae human reading speed of 200wpm
  def self.reading_time(html)
    word_count = html.gsub(/<[^>]+>/, "").split.length

    minutes = [(word_count / 200.0).ceil, 1].max
    "#{minutes} min read"
  end
end