---
title: Tags
subtitle: Browse by topic.
permalink: /tags/
description: All posts grouped by tag.
---

{%- assign tags = site.tags | sort -%}
{%- if tags.size == 0 %}
<p class="empty">No tags yet — add <code>tags: [one, two]</code> to a post's front matter.</p>
{%- else %}

<nav class="tag-cloud" aria-label="All tags">
  {%- for tag in tags %}
  <a class="tag tag-lg" href="#{{ tag[0] | slugify }}">{{ tag[0] }}<span class="tag-count">{{ tag[1].size }}</span></a>
  {%- endfor %}
</nav>

{%- for tag in tags %}
<section class="tag-group" id="{{ tag[0] | slugify }}">
  <h2>{{ tag[0] }}</h2>
  <ul class="archive-list">
    {%- for post in tag[1] %}
    <li>
      <time datetime="{{ post.date | date: "%Y-%m-%d" }}">{{ post.date | date: "%b %-d, %Y" }}</time>
      <a href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
    </li>
    {%- endfor %}
  </ul>
</section>
{%- endfor %}

{%- endif %}
