---
layout: page
permalink: /jp/research-topics/
title: 研究トピック
title_en: Research Topics
nav: false
nav_key: research-topics
lang_variant: ja
forced_lang: ja
url_ja: /jp/research-topics/
url_en: /en/research-topics/
description: ""
description_en: ""
---
{% assign research_topics_ja = site.data.resume.research_topics_ja | default: empty %}
{% assign research_topics_en = site.data.resume.research_topics_en | default: empty %}

<div class="research-topics cv">
  <div class="lang-ja">
    {% include research_topics_cards.html topics=research_topics_ja %}
  </div>

  <div class="lang-en">
    {% include research_topics_cards.html topics=research_topics_en publications_title="Selected Publications" %}
  </div>
</div>
