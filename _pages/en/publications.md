---
layout: page
permalink: /en/publications/
title: 研究業績
title_en: Research Achievements
nav: false
nav_key: publications
lang_variant: en
forced_lang: en
url_ja: /jp/publications/
url_en: /en/publications/
description: ""
description_en: ""
---
{% assign cv_ja_entries = site.data.resume.cv_ja | default: site.data.cv_ja %}
{% assign cv_en_entries = site.data.resume.cv_en | default: empty %}

<div class="publications cv">
  <div class="lang-ja">
    {% include publications_ja_cards.html entries=cv_ja_entries section_titles="論文・発表|招待講演|受賞|プレスリリース・取材|OSS" %}
  </div>

  <div class="lang-en">
    {% include publications_ja_cards.html entries=cv_en_entries section_titles="Publications and Presentations" %}
  </div>
</div>
