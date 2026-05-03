---
title: Welcome
date: 2026-05-03
description: Your first post is live. Here is what to do next.
---

You're up and running. Here's a quick reference for what you can do.

## Adding Posts

Drop any `.md` file into your `pages/` directory (or the directory you set in `config/settings.yml`). It's immediately live at `/<filename>` without needing a restart.

## Frontmatter

Every post can have a frontmatter block at the top:

```yaml
---
title: My Post
date: 2026-05-03
description: A short summary shown on the index and in link previews.
image: /images/cover.png
draft: true
---
```

> All fields are optional. Here's what each does:
> 
> - **`title`**: displayed on the post page and index. Falls back to "Untitled" if omitted.
> 
> - **`date`**: must be `YYYY-MM-DD` format. Posts are sorted newest first on the index. Posts without a date sink to the bottom.
> 
> - **`description`**: shown on the index card below the title, and used as the meta description for link previews on Discord, Twitter, etc.
> 
> - **`image`**: path to a cover image, shown below the description on the post page. Also used as the Open Graph image when sharing the link. Can be a local path (`/images/cover.png`) or an external URL (`https://example.com/photo.png`). **Local images go in `public/images/`. Skip the `public/` when referencing them.**
> 
> - **`draft`**: set to `true` to hide the post from the index. Still accessible via direct URL. Useful for sharing previews before publishing. Remove or set to `false` when ready to publish.


## Images in post

Control size with a modifier in the alt text:

```markdown
![Alt text|small](/images/photo.png)
![Alt text|medium](/images/photo.png)
![Alt text|large](/images/photo.png)
![Alt text](/images/photo.png)
```

## Configuration

All settings live in `config/settings.yml`. Changes take effect on restart.

## What's Next

- Read the [Markdown Showcase](/markdown-showcase) to see everything the renderer supports.
- Check out a [draft post](/draft-example).
- Edit `config/settings.yml` to your liking.
- Delete this file when you're done with it.