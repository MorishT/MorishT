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
<div class="publications">

<h1><span class="lang-ja">著作・発表</span><span class="lang-en">publications</span></h1>
{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f publications -q @article[year={{y}}], @inproceedings[year={{y}}], @misc[year={{y}}] %}
{% endfor %}


<h1><span class="lang-ja">メディア</span><span class="lang-en">media</span></h1>
{%- for y in page.years_media %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f media -q @*[year={{y}}]* %}
{% endfor %}


<h1><span class="lang-ja">OSS</span><span class="lang-en">oss</span></h1>
{%- for y in page.years_oss %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f oss -q @*[year={{y}}]* %}
{% endfor %}


</div>
