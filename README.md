# Crystal Chalk

A lightweight, self-hostable markdown blog server written in Ruby. Drop `.md` files into a folder, configure a YAML file, and your blog is live. No database, no build step, no accounts.

---

## Features

- Drop a `.md` file in your pages folder, and it is immediately live
- Frontmatter support: title, date, description, cover image, draft mode
- Syntax-highlighted code blocks with configurable Rouge themes
- Theming via `settings.yml`: colours, gradient, favicon
- File watcher to reflect changes to edited posts instantly without a server restart
- Mobile responsive
- Minimal, readable default design

---

## Requirements

- Ruby 4.0+
- Bundler

---

## Quick Start

1. **Clone the repo**
    ```bash
    git clone https://github.com/frozen4917/crystal-chalk.git
    cd crystal-chalk
    ```

2. **Install the required gems**
    ```bash
    bundle install
    ```

3. **Run the server**
    ```bash
    rake
    ```

Then open `http://localhost:4567` (or the port you configured) in your browser.

> [!TIP]
> The server starts in development mode by default. Use `rake prod` for production.

---

## Writing Posts

No long, boring explanation of how to write Markdown or format your images here. The best way to learn how Crystal Chalk handles content is to see it in action. Add a `.md` file to the `pages/` directory and get started! Just save the file and refresh the page. Changes are reflected instantly without a server restart.

> [!TIP]
> Run the development server and check out the included example files! We have provided [`pages/welcome.md`](pages/welcome.md), [`pages/markdown-showcase.md`](pages/markdown-showcase.md), and [`pages/draft-example.md`](pages/draft-example.md). These files demonstrate everything you need to know about formatting, code blocks, and site features.

---

## Configuration

Everything lives in [`config/settings.yml`](config/settings.yml):

### General Settings

| Field | Description | Default |
|-------|-------------|---------|
| `site_title` | Displayed in the header and browser tab | `"My Blog"` |
| `site_description` | Used in OG meta tags for the index page | `""` |
| `site_url` | Full URL of your blog, used for host authorisation in production or OG tags. E.g. "https://blog.site.com/" | `""` |
| `extra_hosts` | Additional allowed hostnames, e.g. www variants | `[]` |
| `og_image` | Fallback OG image for the index page | `""` |
| `port` | Port the server listens on | `4567` |
| `pages_dir` | Directory where `.md` files are read from | `"pages"` |
| `code_theme` | Rouge syntax highlight theme for code blocks | `"github.dark"` |

### Theme Settings
Visual settings must be nested under the `theme:` key in your `settings.yml`.

| Field | Description | Default |
|-------|-------------|---------|
| `background_color` | Page background | `"0a0a0a"` |
| `text_color` | Main text colour | `"e8e8f0"` |
| `accent_color` | Links, hover states, borders | `"36339e"` |
| `gradient_color` | Top gradient glow colour | `"727fcd"` |
| `enable_gradient` | Toggle the top gradient on or off | `true` |
| `favicon` | Path to favicon, e.g. `/images/favicon.png` | `"favicon.ico"` |

To see all available code themes:
```bash
rougify help style
```

Changes to `settings.yml` take effect on server restart.

---

## Rake Tasks

```bash
rake                # Start in development mode
rake dev            # Same as rake
rake prod           # Start in production mode
rake routes         # Print all registered routes
rake clean          # Delete generated rouge.css
```

---

## Deployment

See [ADVANCED.md](ADVANCED.md) for full deployment instructions, including Caddy, Nginx, systemd, and subdomain setup.

> [!WARNING]
> In production, set `site_url` in `settings.yml` to your blog's full URL. Crystal Chalk uses this to enforce host authorisation, block unauthorised requests, and for OG tags.

---

## Why Ruby?

Crystal Chalk was built with Ruby and Sinatra deliberately, partly to learn Ruby beyond the usual JavaScript and Python stack, and partly because Sinatra maps very cleanly to this kind of lightweight server. The codebase is readable enough that you do not need to know Ruby to follow it.

If you are more familiar with Node or Python, the concepts translate directly. The architecture is straightforward: a config loader, a markdown renderer, a post cache, and a few routes.

---

## Licence

[MIT](LICENSE) - Frozen, 2026