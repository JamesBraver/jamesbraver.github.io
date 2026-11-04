---
title: "Writing in Markdown, attaching files"
date: 2026-11-01 10:30:00 +0800
tags: [markdown, workflow]
description: >-
  A reference post: everything Markdown can do here, plus how images and other
  binary attachments are stored and linked.
---

This post doubles as a formatting reference. Keep it around, or delete it once
you've got the hang of things.

## Headings, emphasis, links

Text can be **bold**, *italic*, ~~struck through~~, and `inline code`. Links
look like [this one](https://jekyllrb.com/), and bare URLs autolink:
https://github.github.com/gfm/

> A blockquote for the things other people said better than I could.
> It can run onto a second line.

## Lists

1. Ordered items
2. Support nesting
   - like this
   - and this
3. Back to the top level

- Unordered lists work too
- With the same nesting rules

## Code blocks

Fenced blocks are highlighted by Rouge at build time — no client-side
JavaScript involved.

```python
from pathlib import Path

def word_count(path: Path) -> int:
    """Count words in a Markdown file."""
    return len(path.read_text(encoding="utf-8").split())
```

```bash
bundle exec jekyll build          # write the site into _site/
python3 -m http.server -d _site   # preview it at localhost:8000
```

## Tables

| Field       | Where                  | Required |
| ----------- | ---------------------- | -------- |
| `title`     | front matter           | yes      |
| `date`      | front matter or name   | yes      |
| `tags`      | front matter           | no       |
| attachments | `assets/media/`        | no       |

## Image attachments

Drop the file into `assets/media/` and reference it with the `relative_url`
filter so the link survives being hosted under a subpath:

![A dark card reading "Writing in Markdown"]({{ '/assets/media/markdown-card.png' | relative_url }})

The source for that image:

{% raw %}
```markdown
![A dark card reading "Writing in Markdown"]({{ '/assets/media/markdown-card.png' | relative_url }})
```
{% endraw %}

## Any other binary

Non-image files are copied into the built site untouched — no processing, no
re-encoding, no size limit from Jekyll. Link to them and the browser downloads
them:

<p class="attachment"><span class="attachment-label">PDF</span> <a href="{{ '/assets/media/sample-attachment.pdf' | relative_url }}">sample-attachment.pdf</a> <span class="post-meta">1 KB</span></p>

{% raw %}
```markdown
[Download the PDF]({{ '/assets/media/sample-attachment.pdf' | relative_url }})
```
{% endraw %}

Two rules worth remembering:

- Attachments are **binary in git**. A video or a large dataset will bloat the
  repository forever; for anything bigger than a few megabytes, host it
  elsewhere and link to it.
- Filenames are part of the public URL. Lowercase, hyphens, no spaces.

## Footnotes

Kramdown supports footnotes,[^1] which is handy for asides that would interrupt
the flow.

[^1]: Written like this: `[^1]` at the reference and `[^1]: text` at the bottom.

---

That's the whole vocabulary. Write, push, done.
