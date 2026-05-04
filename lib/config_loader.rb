require "psych"
require_relative "utils"

module ConfigLoader
  # Get the relative path to settings.yml: ../config/settings.yml
  SETTINGS_PATH = File.join(__dir__, "..", "config", "settings.yml")

  DEFAULTS = {
    "site_title" => "My Blog",
    "site_description" => "A blog powered by Crystal Chalk",
    "site_url" => "",
    "extra_hosts" => [],
    "og_image" => "",
    "port" => 4567,
    "pages_dir" => "pages",
    "code_theme" => "github.dark",
    "theme" => {
      "background_color" => "0a0a0a",
      "text_color" => "e8e8f0",
      "accent_color" => "36339e",
      "gradient_color" => "727fcd",
      "enable_gradient" => true,
      "favicon" => "favicon.ico"
    }
  }.freeze

  # Loads settings.yml and merges it over DEFAULTS.
  # Nested hashes (e.g. theme) are merged key-by-key so partial overrides work. 
  # All color fields are normalised and validated; invalid values fall back to defaults.
  def self.load 
    raw = Psych.safe_load(File.read(SETTINGS_PATH), permitted_classes: []) || {}

    # Merge Defaults and user's settings from config.yml
    merged = DEFAULTS.merge(raw) do |key, default_val, user_val|
      # Deep merge one level down for nested hashes like theme
      if default_val.is_a?(Hash) && user_val.is_a?(Hash)
        default_val.merge(user_val)
      else
        user_val
      end
    end

    # Normalise and validate all color fields
    theme = merged["theme"]
    theme["background_color"] = Utils.normalize_color(theme["background_color"])  || DEFAULTS["theme"]["background_color"]
    theme["text_color"]       = Utils.normalize_color(theme["text_color"])        || DEFAULTS["theme"]["text_color"]
    theme["accent_color"]     = Utils.normalize_color(theme["accent_color"])      || DEFAULTS["theme"]["accent_color"]
    theme["gradient_color"]   = Utils.normalize_color(theme["gradient_color"])    || DEFAULTS["theme"]["gradient_color"]

    merged
  end
end