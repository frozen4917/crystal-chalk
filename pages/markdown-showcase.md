---
title: Markdown Showcase
date: 2026-05-02
description: Every markdown feature supported by Crystal Chalk, all in one place.
image: https://www.markdownguide.org/assets/images/markdown-mark-white.svg
---

Everything below renders using Redcarpet with Rouge syntax highlighting. Use this as a reference when writing posts.

---

## Headings

# Heading 1
## Heading 2
### Heading 3
#### Heading 4

---

## Text Formatting

Regular paragraph text. **Bold text** and *italic text* and ***bold italic***. ~~Strikethrough~~ works too.

---

## Inline Code

Reference things like `ruby bin/server` or `settings.yml` inline without breaking reading flow.

---

## Blockquote

> This is a blockquote. Useful for pulling out a key idea or quoting something.
>
> It can span multiple paragraphs.

---

## Horizontal Rule

Three dashes on their own line:

---

## Links

[External link](https://github.com/frozen4917/crystal-chalk)

[Link to another post](/welcome)

---

## Lists

Unordered:

- First item
- Second item
- Third item
  - Nested item
  - Another nested item

Ordered:

1. First step
2. Second step
3. Third step

---

## Tables

| Gem | Primary Component | Colour |
|----------|-----------|------------------|
| Ruby | Aluminium Oxide with Chromium | Red |
| Sapphire | Aluminium Oxide with Iron | Usually blue |
| Diamond | Carbon | Colourless |

Tables scroll horizontally on mobile.

---

## Images

Default (its max width):

![Popcat](https://cdn.discordapp.com/emojis/853633015954931733.webp?size=128&animated=true)

Large:

![Popcat|large](https://cdn.discordapp.com/emojis/853633015954931733.webp?size=128&animated=true)

Medium:

![Popcat|medium](https://cdn.discordapp.com/emojis/853633015954931733.webp?size=128&animated=true)

Small:

![Popcat|small](https://cdn.discordapp.com/emojis/853633015954931733.webp?size=128&animated=true)

---

## Code Blocks

Fenced code blocks with a language tag get syntax highlighting automatically:

```ruby
def hello
  puts "Hello, world!"
end
```

To see all available languages:

```bash
rougify list
```

## Syntax Highlight Theme

The code block color theme is set in `config/settings.yml`:

```yaml
code_theme: "base16.monokai.dark"
```

To see all available themes:

```bash
rougify help style
```

Then restart the server. The theme regenerates automatically on startup.

---

## Draft Posts

Want to see a post that's hidden from the index but accessible by URL?

Visit the [draft example](/draft-example). It won't appear in the post list but the direct link works.