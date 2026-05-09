---
layout: page
permalink: /publications/
title: 研究業績
title_en: Research Achievements
description: ""
description_en: ""
nav: true
nav_order: 2
---
<!-- _pages/publications.md -->
{% assign cv_ja_entries = site.data.resume.cv_ja | default: site.data.cv_ja %}
{% assign cv_en_entries = site.data.resume.cv_en | default: empty %}

<div class="publications cv">
  <div class="lang-ja">
    {% include publications_ja_cards.html entries=cv_ja_entries section_titles="論文・発表|招待講演|受賞|プレスリリース・取材|OSS" %}
  </div>

  <div class="lang-en">
    {% include publications_ja_cards.html entries=cv_en_entries section_titles="Publications and Presentations|Invited Talks|Awards|Press Releases and Media|OSS" %}
  </div>
</div>
