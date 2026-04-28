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
{% assign publication_section_titles = "論文・発表|招待講演|受賞|プレスリリース・取材|OSS" | split: "|" %}

<div class="publications cv">
  <div class="lang-ja">
    {% for section_title in publication_section_titles %}
      {% for entry in cv_ja_entries %}
        {% unless entry.hide %}
          {% if entry.title == section_title %}
            {% if entry.type == "subsections" %}
              {% for subsection in entry.contents %}
                <div class="card mt-3 p-3">
                  <h3 class="card-title font-weight-medium">{{ subsection.title }}</h3>
                  <div>
                    {% if subsection.type == "time_table" %}
                      <ul class="card-text font-weight-light list-group list-group-flush">
                        {% for content in subsection.contents %}
                          {% assign badge_label = content.badge | default: content.year %}
                          {% assign show_year_as_meta = false %}
                          {% if content.badge and content.year %}
                            {% assign show_year_as_meta = true %}
                          {% endif %}
                          <li class="list-group-item">
                            <div class="row cv-time-row">
                              {% if badge_label %}
                                <div class="col-auto text-center cv-time-badge">
                                  {% assign badge_label_html = badge_label | replace_first: ' ', '<br>' %}
                                  <span class="badge font-weight-bold align-middle{% if content.badge_theme %} cv-badge-{{ content.badge_theme }}{% endif %}">
                                    {{ badge_label_html }}
                                  </span>
                                </div>
                              {% endif %}
                              <div class="col mt-2 mt-md-0 cv-time-content">
                                {% if content.title %}
                                  <h6 class="title ml-1 mb-0 cv-time-title" style="font-weight: {% if content.emphasize_title %}700{% elsif content.normal_weight_title %}400{% else %}700{% endif %};">{% if content.emphasize_title %}<span style="text-decoration: underline;">{{ content.title }}</span>{% else %}{{ content.title }}{% endif %}{% if content.institution_url %} <a href="{{ content.institution_url | escape }}" target="_blank" rel="noopener noreferrer">[link]</a>{% endif %}</h6>
                                {% endif %}
                                {% if content.authors_html %}
                                  <div class="cv-time-authors ml-1">{{ content.authors_html }}</div>
                                {% endif %}
                                {% if content.institution %}
                                  <h6 class="ml-1 cv-time-institution" style="font-size: 0.95rem; font-weight: {% if content.emphasize_institution %}700{% elsif content.normal_weight_institution %}400{% else %}300{% endif %};">{% if content.emphasize_institution or content.underline_institution %}<span style="text-decoration: underline;">{{ content.institution }}</span>{% else %}{{ content.institution }}{% endif %}</h6>
                                {% endif %}
                                {% if content.description %}
                                  <ul class="items">
                                    {% for item in content.description %}
                                      <li>
                                        {% if item.contents %}
                                          <span class="item-title">{{ item.title }}</span>
                                          <ul class="subitems">
                                            {% for subitem in item.contents %}
                                              <li><span class="subitem">{{ subitem }}</span></li>
                                            {% endfor %}
                                          </ul>
                                        {% else %}
                                          <span class="item">{{ item }}</span>
                                        {% endif %}
                                      </li>
                                    {% endfor %}
                                  </ul>
                                {% endif %}
                                {% if content.items %}
                                  <ul class="items">
                                    {% for item in content.items %}
                                      <li>
                                        {% if item.contents %}
                                          <span class="item-title">{{ item.title }}</span>
                                          <ul class="subitems">
                                            {% for subitem in item.contents %}
                                              <li><span class="subitem">{{ subitem }}</span></li>
                                            {% endfor %}
                                          </ul>
                                        {% else %}
                                          <span class="item">{{ item }}</span>
                                        {% endif %}
                                      </li>
                                    {% endfor %}
                                  </ul>
                                {% endif %}
                              </div>
                              {% if show_year_as_meta %}
                                <div class="col-auto mt-2 mt-md-0 text-right cv-time-year">
                                  <span class="cv-time-meta">{{ content.year }}</span>
                                </div>
                              {% endif %}
                            </div>
                          </li>
                        {% endfor %}
                      </ul>
                    {% elsif subsection.type == "list" %}
                      <ul class="card-text font-weight-light list-group list-group-flush">
                        {% for content in subsection.contents %}
                          <li class="list-group-item">{{ content }}</li>
                        {% endfor %}
                      </ul>
                    {% elsif subsection.type == "nested_list" %}
                      <ul class="card-text font-weight-light list-group list-group-flush">
                        {% for content in subsection.contents %}
                          <li class="list-group-item">
                            <h5 class="font-italic">{{ content.title }}</h5>
                            {% if content.text %}
                              <div class="subitems">{{ content.text }}</div>
                            {% endif %}
                            {% if content.items %}
                              <ul class="subitems">
                                {% for subitem in content.items %}
                                  <li><span class="subitem">{{ subitem }}</span></li>
                                {% endfor %}
                              </ul>
                            {% endif %}
                          </li>
                        {% endfor %}
                      </ul>
                    {% elsif subsection.type == "map" %}
                      <table class="table table-sm table-borderless table-responsive">
                        {% for content in subsection.contents %}
                          <tr>
                            <td class="p-1 pr-2 font-weight-bold"><b>{{ content.name }}</b></td>
                            <td class="p-1 pl-2 font-weight-light text">{{ content.value }}</td>
                          </tr>
                        {% endfor %}
                      </table>
                    {% else %}
                      {{ subsection.contents }}
                    {% endif %}
                  </div>
                </div>
              {% endfor %}
            {% else %}
              {% include cv/render_section.html entry=entry %}
            {% endif %}
          {% endif %}
        {% endunless %}
      {% endfor %}
    {% endfor %}
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
