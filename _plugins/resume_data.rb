require "csv"
require "bibtex"
require "fileutils"

module Jekyll
  class ResumeDataGenerator < Generator
    SELF_AUTHOR_NAMES = ["森下 皓文", "Terufumi Morishita"].freeze
    CJK_REGEX = /[\p{Han}\p{Hiragana}\p{Katakana}]/

    safe true
    priority :highest

    def generate(site)
      resume_data_dir = File.join(site.source, "resume", "data")
      ensure_resume_data_dir!(resume_data_dir)

      site.data["resume"] ||= {}
      site.data["resume"]["about_ja"] = read_optional_file(File.join(resume_data_dir, "about.md"))
      site.data["resume"]["cv_ja"] = build_cv_ja(site, resume_data_dir)

      sync_publications_bib!(site, resume_data_dir)
    end

    private

    def ensure_resume_data_dir!(resume_data_dir)
      return if Dir.exist?(resume_data_dir)

      raise Jekyll::Errors::FatalException, "resume/data not found. Run `git submodule update --init --recursive` first."
    end

    def read_optional_file(path)
      return nil unless File.exist?(path)

      File.read(path)
    end

    def sync_publications_bib!(site, resume_data_dir)
      source_path = File.join(resume_data_dir, "publications.bib")
      dest_path = File.join(site.source, "_bibliography", "publications.bib")

      unless File.exist?(source_path)
        raise Jekyll::Errors::FatalException, "Missing bibliography source: #{source_path}"
      end

      source_content = File.read(source_path)
      FileUtils.mkdir_p(File.dirname(dest_path))

      return if File.exist?(dest_path) && File.read(dest_path) == source_content

      File.write(dest_path, source_content)
    end

    def build_cv_ja(site, resume_data_dir)
      bibliography = load_bibliography(resume_data_dir)
      sections = [
        build_research_section(resume_data_dir),
        build_education_section(resume_data_dir),
        build_work_section(resume_data_dir),
        build_publications_section(bibliography),
        build_invited_talks_section(bibliography),
        build_press_section(bibliography),
        build_oss_section(bibliography),
        build_awards_section(resume_data_dir),
        build_academic_service_section(site, resume_data_dir),
      ].compact
      section_titles = sections.map { |section| section["title"] }
      local_sections = Array(site.data["cv_ja_local"]).reject do |section|
        section_titles.include?(section["title"])
      end

      [
        *sections[0...-1],
        *local_sections,
        sections.last,
      ].compact
    end

    def read_csv(path)
      CSV.read(path, headers: true).map(&:to_h)
    end

    def load_bibliography(resume_data_dir)
      BibTeX.parse(File.read(File.join(resume_data_dir, "publications.bib")))
    end

    def normalize_period(period)
      period.to_s.strip.gsub(/\s+--\s+/, " - ")
    end

    def compact_strings(values)
      values.map { |value| value.to_s.strip }.reject(&:empty?)
    end

    def build_education_section(resume_data_dir)
      rows = read_csv(File.join(resume_data_dir, "education.csv"))
      contents = rows.sort_by { |row| row["order"].to_i }.map do |row|
        description = compact_strings(
          [
            ("研究テーマ: #{row['field']}" unless row["field"].to_s.strip.empty?),
            ("指導教員: #{row['advisor']}" unless row["advisor"].to_s.strip.empty?),
            row["thesis"],
          ]
        )

        {
          "title" => row["degree"],
          "institution" => row["institution"],
          "year" => normalize_period(row["period"]),
          "description" => description.empty? ? nil : description,
        }
      end

      {
        "title" => "学歴",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_research_section(resume_data_dir)
      about_path = File.join(resume_data_dir, "about.md")
      return nil unless File.exist?(about_path)

      contents = File.readlines(about_path, chomp: true).filter_map do |line|
        stripped = line.strip
        next unless stripped.start_with?("- ")

        stripped.sub(/\A-\s+/, "")
      end

      return nil if contents.empty?

      {
        "title" => "研究分野",
        "type" => "list",
        "contents" => contents,
      }
    end

    def build_work_section(resume_data_dir)
      positions = read_csv(File.join(resume_data_dir, "work_positions.csv"))
      projects = read_csv(File.join(resume_data_dir, "work_projects.csv"))
      projects_by_position = projects.group_by { |row| row["position_id"] }

      contents = positions.sort_by { |row| row["order"].to_i }.map do |row|
        project_lines = Array(projects_by_position[row["id"]])
          .sort_by { |project| project["order"].to_i }
          .map do |project|
            project["title"].to_s.strip
          end

        {
          "title" => row["organization"],
          "year" => normalize_period(row["period"]),
          "description" => project_lines.empty? ? nil : project_lines,
        }
      end

      {
        "title" => "職歴",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_publications_section(bibliography)
      contents = [
        build_bibliography_subsection("論文誌", bibliography, label: "journal", badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_subsection("国際学会", bibliography, label: "international-conference", badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_subsection("国内学会", bibliography, label: "domestic-conference", badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_subsection("テックブログ", bibliography, label: "blog", badge_fields: %i[tag abbr], fallback_badge: "ブログ", fallback_institution: "blog", include_authors: true),
      ].compact

      return nil if contents.empty?

      {
        "title" => "論文・発表",
        "type" => "subsections",
        "contents" => contents,
      }
    end

    def build_awards_section(resume_data_dir)
      rows = read_csv(File.join(resume_data_dir, "awards.csv"))
      contents = rows.map do |row|
        award_title = row["award"].to_s.strip
        award_tag = row["tag"].to_s.strip
        {
          "title" => row["event"].to_s.strip,
          "institution" => award_title,
          "year" => row["year"].to_s.strip,
          "badge" => award_tag.empty? ? nil : award_tag,
          "badge_theme" => award_tag.empty? ? nil : "purple",
          "emphasize_institution" => award_title.include?("(主著)"),
          "normal_weight_institution" => true,
          "normal_weight_title" => true,
        }
      end

      {
        "title" => "受賞",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_invited_talks_section(bibliography)
      build_bibliography_time_table("招待講演", bibliography, label: "invited-talk", badge_fields: %i[tag abbr], badge_theme: "purple")
    end

    def build_press_section(bibliography)
      build_bibliography_time_table("プレスリリース・取材", bibliography, label: "press", badge_fields: %i[tag abbr], fallback_badge: "プレス")
    end

    def build_oss_section(bibliography)
      build_bibliography_time_table("OSS", bibliography, label: "oss", badge_fields: %i[tag abbr], fallback_badge: "OSS")
    end

    def build_academic_service_section(site, resume_data_dir)
      rows = read_csv(File.join(resume_data_dir, "academic_service.csv"))
      contents = rows.sort_by { |row| row["order"].to_i }.map do |row|
        items = compact_strings(row["summary"].to_s.split(/\s*\/\s*/))
        content = {
          "title" => row["title"],
        }

        if row["title"].to_s.include?("査読")
          content["text"] = items.join(" / ")
        else
          content["items"] = items
        end

        content
      end

      {
        "title" => "学術貢献活動",
        "type" => "nested_list",
        "hide" => true,
        "contents" => contents,
      }
    end

    def build_bibliography_subsection(title, bibliography, label:, selected: false, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      contents = build_bibliography_contents(
        bibliography,
        label: label,
        selected: selected,
        badge_fields: badge_fields,
        fallback_badge: fallback_badge,
        badge_theme: badge_theme,
        fallback_institution: fallback_institution,
        include_authors: include_authors
      )
      return nil if contents.empty?

      {
        "title" => title,
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_bibliography_time_table(title, bibliography, label:, selected: false, badge_fields: [], fallback_badge: nil, badge_theme: nil)
      contents = build_bibliography_contents(
        bibliography,
        label: label,
        selected: selected,
        badge_fields: badge_fields,
        fallback_badge: fallback_badge,
        badge_theme: badge_theme
      )
      return nil if contents.empty?

      {
        "title" => title,
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_bibliography_contents(bibliography, label:, selected: false, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      bibliography.each_with_index.filter_map do |entry, index|
        next unless bibliography_entry_match?(entry, label, selected: selected)

        build_bibliography_content(
          entry,
          index,
          badge_fields: badge_fields,
          fallback_badge: fallback_badge,
          badge_theme: badge_theme,
          fallback_institution: fallback_institution,
          include_authors: include_authors
        )
      end.sort_by { |content| [-content.delete("_sort_year").to_i, content.delete("_sort_index").to_i] }
    end

    def build_bibliography_content(entry, index, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      title = normalize_bibtex_text(bibtex_field(entry, :title))
      return nil if title.empty?

      badge = normalize_bibtex_text(bibtex_field(entry, *badge_fields))
      badge = fallback_badge.to_s.strip if badge.empty? && fallback_badge

      institution = normalize_bibtex_text(
        bibtex_field(entry, :journaltitle, :journal, :booktitle, :publisher, :howpublished, :organization, :abbr)
      )
      institution = fallback_institution.to_s.strip if institution.empty? && fallback_institution
      institution = "" if !badge.empty? && institution == badge
      url = normalize_bibtex_text(bibtex_field(entry, :url))

      description = compact_strings(
        [
          bibliography_link_item(url, institution.empty?),
        ]
      )

      content = {
        "title" => title,
        "year" => normalize_bibtex_text(bibtex_field(entry, :year)),
        "normal_weight_title" => true,
        "_sort_year" => bibtex_field(entry, :year).to_i,
        "_sort_index" => index,
      }
      content["badge"] = badge unless badge.empty?
      content["badge_theme"] = badge_theme unless badge.empty? || badge_theme.to_s.strip.empty?
      content["institution"] = institution unless institution.empty?
      content["underline_institution"] = true unless institution.empty?
      content["institution_url"] = url unless url.empty? || institution.empty?
      institution_meta_html = bibliography_institution_meta_html(entry)
      content["institution_meta_html"] = institution_meta_html unless institution_meta_html.empty?
      authors = bibliography_authors_html(entry)
      content["authors_html"] = authors if include_authors && !authors.empty?
      content["description"] = description unless description.empty?
      content
    end

    def bibliography_authors_html(entry)
      author_field = bibtex_field(entry, :author)
      return "" if author_field.empty?

      author_field
        .split(/\s+and\s+/)
        .map { |author| format_bibliography_author(author) }
        .reject(&:empty?)
        .join(", ")
    end

    def format_bibliography_author(author)
      stripped = normalize_bibtex_text(author).gsub(/[{}]/, "").strip
      return "" if stripped.empty?

      if stripped.include?(",")
        last, first = stripped.split(",", 2).map(&:strip)
        display = if first.empty?
                    last
                  elsif cjk_name?(first) || cjk_name?(last)
                    "#{last} #{first}"
                  else
                    "#{first} #{last}"
                  end
      else
        display = stripped
      end

      return %(<span class="cv-self-author">#{display}</span>) if SELF_AUTHOR_NAMES.include?(display)

      display
    end

    def cjk_name?(name)
      CJK_REGEX.match?(name.to_s)
    end

    def bibliography_acceptance_rate(entry)
      acceptance_rate = normalize_bibtex_text(bibtex_field(entry, :acceptance_rate, :usera))
      return nil if acceptance_rate.empty?

      "採択率: #{acceptance_rate}"
    end

    def bibliography_note_item(entry)
      note = normalize_bibtex_text(bibtex_field(entry, :note))
      return nil if note.empty?

      note
    end

    def bibliography_institution_meta_html(entry)
      fragments = []
      note = bibliography_note_item(entry)
      acceptance_rate = bibliography_acceptance_rate(entry)

      fragments << %(<span class="cv-time-inline-meta cv-time-inline-note">#{note}</span>) unless note.nil?
      fragments << %(<span class="cv-time-inline-meta cv-time-inline-acceptance">#{acceptance_rate}</span>) unless acceptance_rate.nil?
      return "" if fragments.empty?

      fragments.join(" ")
    end

    def bibliography_link_item(url, include_link)
      return nil if url.empty? || !include_link

      %(<a href="#{url}">link</a>)
    end

    def bibliography_entry_match?(entry, label, selected: false)
      keywords = bibtex_keywords(entry)
      return false if selected && !keywords.include?("selected")

      case label
      when "journal"
        keywords.include?("journal")
      when "international-conference"
        keywords.include?("international")
      when "domestic-conference"
        keywords.include?("domestic") && !keywords.include?("talk")
      when "invited-talk"
        keywords.include?("talk")
      when "press"
        keywords.include?("media")
      when "blog"
        keywords.include?("blog")
      when "oss"
        keywords.include?("oss")
      else
        false
      end
    end

    def bibtex_keywords(entry)
      bibtex_field(entry, :keywords).split(",").map { |keyword| keyword.strip.downcase }.reject(&:empty?)
    end

    def bibtex_field(entry, *fields)
      fields.each do |field|
        value = entry[field].to_s.strip
        return value unless value.empty?
      end

      ""
    end

    def normalize_bibtex_text(value)
      value.to_s.strip.gsub("\\%", "%")
    end
  end
end
