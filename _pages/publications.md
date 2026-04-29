---
layout: page
permalink: /publications/
title: 研究業績
title_en: publications
description: ""
description_en: ""
years: [2026, 2025, 2024, 2023, 2022, 2021, 2020, 2019]
years_media: [2024, 2023, 2020, 2019]
years_oss: [2023, 2022]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
{% assign cv_ja_entries = site.data.resume.cv_ja | default: site.data.cv_ja %}

<div class="publications cv">
  <div class="lang-ja">
    {% include publications_ja_cards.html entries=cv_ja_entries section_titles="論文・発表|招待講演|受賞|プレスリリース・取材|OSS" %}
  </div>

  <div class="lang-en">
    <h1>Publications</h1>
    {%- for y in page.years %}
      <h2 class="year">{{y}}</h2>
      {% bibliography -f publications -q @article[year={{y}}], @inproceedings[year={{y}}], @misc[year={{y}}] %}
    {% endfor %}

    <h1>Media</h1>
    {%- for y in page.years_media %}
      <h2 class="year">{{y}}</h2>
      {% bibliography -f media -q @*[year={{y}}]* %}
    {% endfor %}

    <h1>OSS</h1>
    {%- for y in page.years_oss %}
      <h2 class="year">{{y}}</h2>
      {% bibliography -f oss -q @*[year={{y}}]* %}
    {% endfor %}

    {% for entry in site.data.cv %}
      {% unless entry.hide %}
        {% if entry.title == "Invited Talks" or entry.title == "Honors and Awards" %}
          {% include cv/render_section.html entry=entry %}
        {% endif %}
      {% endunless %}
    {% endfor %}
  </div>
</div>
