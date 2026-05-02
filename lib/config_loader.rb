require "psych"
require_relative "utils"

module ConfigLoader
  # Get the relative path to settings.yml: ../config/settings.yml
  SETTINGS_PATH = File.join(__dir__, "..", "config", "settings.yml")

  DEFAULTS = {
    "site_title" => "My Blog",
    "port" => 4567,
    "site_url" => "",
    "og_image" => "",
    "pages_dir" => "pages",
    "code_theme" => "github.dark",
    "theme" => {
      "background_color" => "1a1a2e",
      "text_color" => "e8e8f0",
      "accent_color" => "6f84d6",
      "gradient_color" => "6c63ff",
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

    theme = merged["theme"]

    # Normalise and validate all color fields
    theme["background_color"] = Utils.normalize_color(theme["background_color"]) || DEFAULTS["theme"]["background_color"]
    theme["text_color"] = Utils.normalize_color(theme["text_color"]) || DEFAULTS["theme"]["text_color"]
    theme["accent_color"] = Utils.normalize_color(theme["accent_color"]) || DEFAULTS["theme"]["accent_color"]
    theme["gradient_color"] = Utils.normalize_color(theme["gradient_color"]) || DEFAULTS["theme"]["gradient_color"]

    merged
  end
end