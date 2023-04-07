---
layout: page
permalink: /publications/
title: publications
description: 
years: [2023, 2022, 2021, 2020, 2019]
years_others: [2019]
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

<h1>others</h1>
{%- for y in page.years_others %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f others -q @*[year={{y}}]* %}
{% endfor %}

</div>
