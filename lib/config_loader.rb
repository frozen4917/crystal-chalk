require "psych"

module ConfigLoader
  # Get the relative path to settings.yml: ../config/settings.yml
  SETTINGS_PATH = File.join(__dir__, "..", "config", "settings.yml")

  DEFAULTS = {
    "site_title" => "My Blog",
    "port" => 4567,
    "pages_dir" => "pages",
    "theme" => {
      "background_color" => "1a1a2e",
      "text_color" => "e8e8f0",
      "accent_color" => "6f84d6",
      "gradient_color":   "6c63ff",
      "enable_gradient" => true,
      "favicon" => ""
    }
  }.freeze

  def self.load 
    raw = Psych.safe_load(File.read(SETTINGS_PATH), permitted_classes: []) || {}

    # Merge Defaults and user's settings from config.yml
    merged = DEFAULTS.merge(raw) do |key, default_val, user_val|
      if default_val.is_a?(Hash) && user_val.is_a?(Hash)
        default_val.merge(user_val)
      else
        user_val
      end
    end


    # Normalise and validate all color fields
    theme = merged["theme"]
    theme["background_color"] = normalize_color(theme["background_color"]) || DEFAULTS["theme"]["background_color"]
    theme["text_color"] = normalize_color(theme["text_color"]) || DEFAULTS["theme"]["text_color"]
    theme["gradient_color"] = normalize_color(theme["gradient_color"]) || DEFAULTS["theme"]["gradient_color"]
    theme["accent_color"] = normalize_color(theme["accent_color"]) || DEFAULTS["theme"]["accent_color"]

    merged
  end

  def self.normalize_color(value)
    # Strip whitespace and leading # if present
    hex = value.to_s.strip.delete_prefix("#")

    # Check for valid hex code (exactly 3 or 6 chars, all 0-9 or a-f (case-insensitive))
    if hex.match?(/\A[0-9a-fA-F]{3}\z/) || hex.match?(/\A[0-9a-fA-F]{6}\z/)
      hex # Return the hex code
    else
      puts "[Geode Blog] Warning: '#{value}' is not a valid hex color. Using the default value."
      nil # Return nil
    end
  end
end