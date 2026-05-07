---
layout: page
permalink: /research-topics/
title: 研究トピック
title_en: Research Topics
description: ""
description_en: ""
nav: true
nav_order: 1
---

{% assign research_topics = site.data.resume.research_topics_ja | default: empty %}

<div class="research-topics cv">
  <div class="lang-ja">
    {% include research_topics_cards.html topics=research_topics %}
  </div>

  <div class="lang-en">
    {% include research_topics_cards.html topics=research_topics %}
  </div>
</div>
