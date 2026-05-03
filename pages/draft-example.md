---
title: This is a Draft
date: 2026-05-03
description: Draft posts are hidden from the index but accessible via direct URL.
draft: true
---

This post has `draft: true` in its frontmatter, hence, it won't appear on the index page, but anyone with the direct link can read it.

## How Drafts Work

Add this to your frontmatter:

```yaml
draft: true
```

That's it. The post is immediately hidden from the index on the next request. No restart needed.

## Use Cases

- Share a post with someone for feedback before publishing
- Keep work-in-progress posts in the repo without them going live
- Stage content ahead of time

## Publishing

When you're ready to publish, either remove the `draft` field entirely or set it to `false`:

```yaml
draft: false
```

The post will appear in the index on the next request, sorted by date alongside your other posts.

## A Note on Privacy

Draft posts are hidden from the index but **not password protected**. Anyone who knows the URL can read them. If your repo is public, the `.md` file is also visible on GitHub.

For truly private content, don't commit it until you're ready to publish.