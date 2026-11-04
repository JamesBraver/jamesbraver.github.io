---
title: "Hello, world"
date: 2026-11-03 09:00:00 +0800
tags: [meta, jekyll]
description: >-
  Why this blog exists, and what the first version of it is made of.
---

This is the first post on a blog that is, on purpose, as small as it can be.

No framework, no build server, no database, no analytics. Just Markdown files
in a git repository, a handful of HTML layouts, and one stylesheet. GitHub
Pages compiles it and serves the result — for free, over HTTPS, on its own CDN.

## What's in the box

- **Markdown posts** in `_posts/`, named `YYYY-MM-DD-title.md`.
- **Binary attachments** in `assets/media/` — images, PDFs, anything.
- **Tags and an archive**, generated at build time from front matter.
- **An RSS feed** and a sitemap, so it works with readers and search engines.
- **Light and dark themes**, following the operating system preference.

## Why keep it this simple?

Static sites don't get slower as they grow, they don't break when a dependency
disappoints you, and they don't need patching. A post is a text file; publishing
is a `git push`. Everything else is decoration.

The trade-off is honest: no comments, no search, no admin panel. If I ever need
those, they can be added without changing what a post fundamentally is — a
Markdown file with a date at the top.

{%- assign guide = site.posts | where_exp: "p", "p.slug == 'writing-in-markdown'" | first -%}
Next: [how to write a post in Markdown]({{ guide.url | relative_url }}).
