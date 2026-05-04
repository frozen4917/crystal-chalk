require "rouge"

module RougeTheme
  VALID_THEMES = %w[
    base16 base16.dark base16.light
    base16.monokai base16.monokai.dark base16.monokai.light
    base16.solarized base16.solarized.dark base16.solarized.light
    bw colorful
    github github.dark github.light
    gruvbox gruvbox.dark gruvbox.light
    igorpro magritte molokai monokai monokai.sublime
    pastie thankful_eyes tulip
  ].freeze

  ROUGE_CSS_PATH = File.join(__dir__, "..", "public", "assets", "rouge.css")

  # Generates rouge.css for the given theme name. Falls back to github.dark if unknown.
  def self.generate(theme_name)
    unless VALID_THEMES.include?(theme_name)
      puts "[Crystal Chalk] Warning: unknown code theme '#{theme_name}'. Falling back to github.dark."
      theme_name = "github.dark"
    end

    theme = Rouge::Theme.find(theme_name)
    if theme.nil?
      puts "[Crystal Chalk] Warning: Rouge could not find theme '#{theme_name}'."
      return
    end

    css = theme.render(scope: ".post-content .highlight")
    File.write(ROUGE_CSS_PATH, css)
    puts "[Crystal Chalk] Code theme set to '#{theme_name}'."
  end
end