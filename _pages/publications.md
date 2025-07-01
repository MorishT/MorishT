---
layout: page
permalink: /publications/
title: publications
description: 
years: [2025, 2024, 2023, 2022, 2021, 2020, 2019]
years_media: [2024, 2023, 2020, 2019]
years_oss: [2023, 2022]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

<h1>my writings</h1>
{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f writings -q @*[year={{y}}]* %}
{% endfor %}


<h1>media</h1>
{%- for y in page.years_media %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f media -q @*[year={{y}}]* %}
{% endfor %}


<h1>oss</h1>
{%- for y in page.years_oss %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f oss -q @*[year={{y}}]* %}
{% endfor %}


</div>
