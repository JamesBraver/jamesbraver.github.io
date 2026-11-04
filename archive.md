---
title: Archive
subtitle: Everything, newest first.
permalink: /archive/
description: All posts by year.
---

{%- assign by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" -%}
{%- if site.posts.size == 0 %}
<p class="empty">Nothing published yet.</p>
{%- else %}
{%- for year in by_year %}
<section class="archive-year">
  <h2 class="year-heading">{{ year.name }}</h2>
  <ul class="archive-list">
    {%- for post in year.items %}
    <li>
      <time datetime="{{ post.date | date: "%Y-%m-%d" }}">{{ post.date | date: "%b %-d" }}</time>
      <a href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
    </li>
    {%- endfor %}
  </ul>
</section>
{%- endfor %}
{%- endif %}
