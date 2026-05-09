require "csv"
require "bibtex"

module Jekyll
  class ResumeDataEnglishGenerator < Generator
    safe true
    priority :highest

    CJK_REGEX = /[\p{Han}\p{Hiragana}\p{Katakana}]/
    SELF_AUTHOR_NAMES = ["森下 皓文", "Terufumi Morishita"].freeze
    RESEARCH_TOPIC_ORDER = %w[FLD ensemble competition economic_simulation NLP_applications speech_recognition dark_matter].freeze
    WORK_RESEARCH_TOPICS_BY_POSITION = {
      "hitachi" => %w[FLD ensemble economic_simulation competition NLP_applications],
      "toshiba" => %w[speech_recognition],
    }.freeze
    BIB_BADGE_EN = {
      "ICML (Spotlight=上位5%)" => "ICML",
      "SemEval (1位)" => "SemEval",
      "SemEval (1位, Oral)" => "SemEval",
      "SemEval (2位)" => "SemEval",
      "CoNLL (1位)" => "CoNLL",
    }.freeze
    NOTE_EN = {
      "Spotlight (上位5%)" => "Spotlight",
      "1位" => "1st place",
      "2位" => "2nd place",
      "Oral, 1位" => "oral presentation, 1st place",
    }.freeze

    def generate(site)
      resume_data_dir = File.join(site.source, "resume", "data")
      return unless Dir.exist?(resume_data_dir)

      bibliography_path = File.join(resume_data_dir, "publications.bib")
      return unless File.exist?(bibliography_path)

      bibliography = BibTeX.parse(File.read(bibliography_path))

      site.data["resume"] ||= {}
      site.data["resume"]["about_en"] = read_optional_resume_data_file(resume_data_dir, "about/about_en.md")
      site.data["resume"]["cv_en"] = build_cv_en(resume_data_dir, bibliography)
      site.data["resume"]["selected_achievements_en"] = build_selected_achievements_en(bibliography)
      site.data["resume"]["research_topics_en"] = build_research_topics_en(site, resume_data_dir, bibliography)
    end

    private

    def read_csv(path)
      CSV.read(path, headers: true).map(&:to_h)
    end

    def resolve_resume_data_file(resume_data_dir, *relative_paths)
      relative_paths.each do |relative_path|
        path = File.join(resume_data_dir, relative_path)
        return path if File.exist?(path)
      end

      nil
    end

    def read_optional_resume_data_file(resume_data_dir, *relative_paths)
      path = resolve_resume_data_file(resume_data_dir, *relative_paths)
      return nil if path.nil?

      File.read(path)
    end

    def read_single_value_file(path)
      return nil unless path && File.exist?(path)

      File.foreach(path) do |line|
        stripped = line.strip
        return stripped unless stripped.empty?
      end

      nil
    end

    def resume_data_web_path(resume_data_dir, path)
      return nil if path.nil?

      relative_path = path.delete_prefix(File.join(resume_data_dir, ""))
      File.join("resume", "data", relative_path)
    end

    def normalize_period(period)
      period.to_s.strip.gsub(/\s+--\s+/, " - ")
    end

    def normalize_period_en(period)
      normalize_period(period).gsub("現在", "Present")
    end

    def compact_strings(values)
      values.map { |value| value.to_s.strip }.reject(&:empty?)
    end

    def international_entry?(entry)
      keywords = bibtex_keywords(entry)
      return true if keywords.include?("international")

      normalize_bibtex_text(bibtex_field(entry, :research_scope)).downcase == "international"
    end

    def bibtex_field(entry, *fields)
      fields.each do |field|
        value = entry[field].to_s.strip
        return value unless value.empty?
      end

      ""
    end

    def bibtex_keywords(entry)
      bibtex_field(entry, :keywords).split(",").map { |keyword| keyword.strip.downcase }.reject(&:empty?)
    end

    def normalize_bibtex_text(value)
      value.to_s.strip.gsub("\\%", "%")
    end

    def cjk_name?(name)
      CJK_REGEX.match?(name.to_s)
    end

    def format_bibliography_author(author)
      stripped = normalize_bibtex_text(author).gsub(/[{}]/, "").strip
      return "" if stripped.empty?

      display =
        if stripped.include?(",")
          last, first = stripped.split(",", 2).map(&:strip)
          if first.empty?
            last
          elsif cjk_name?(first) || cjk_name?(last)
            "#{last} #{first}"
          else
            "#{first} #{last}"
          end
        else
          stripped
        end

      return %(<span class="cv-self-author">#{display}</span>) if SELF_AUTHOR_NAMES.include?(display)

      display
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

    def build_cv_en(resume_data_dir, bibliography)
      [
        build_research_section_en(resume_data_dir),
        build_education_section_en(resume_data_dir),
        build_work_section_en(resume_data_dir),
        build_publications_section_en(bibliography),
      ].compact
    end

    def build_research_section_en(resume_data_dir)
      about_path = resolve_resume_data_file(resume_data_dir, "about/about_en.md")
      return nil if about_path.nil?

      contents = File.readlines(about_path, chomp: true).filter_map do |line|
        stripped = line.strip
        match = stripped.match(/\A[-*]\s+(.+)\z/)
        next if match.nil?

        match[1]
      end
      return nil if contents.empty?

      {
        "title" => "Research Interests",
        "type" => "list",
        "contents" => contents,
      }
    end

    def build_education_section_en(resume_data_dir)
      rows = read_csv(File.join(resume_data_dir, "education.csv"))
      contents = rows.sort_by { |row| row["order"].to_i }.map do |row|
        field = row["field_en"].to_s.strip
        advisor = row["advisor_en"].to_s.strip
        thesis = row["thesis_en"].to_s.strip
        institution_note = row["institution_note_en"].to_s.strip
        description = compact_strings(
          [
            institution_note,
            ("Research Theme: #{field}" unless field.empty?),
            thesis,
            ("Supervisor: #{advisor}" unless advisor.empty?),
          ]
        )

        {
          "title" => row["degree_en"].to_s.strip,
          "institution" => row["institution_en"].to_s.strip,
          "year" => normalize_period_en(row["period_en"].to_s.empty? ? row["period"] : row["period_en"]),
          "match_title_weight_institution" => row["match_title_weight_institution"].to_s.strip == "1",
          "description" => description.empty? ? nil : description,
        }
      end

      {
        "title" => "Education",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_work_section_en(resume_data_dir)
      positions = read_csv(File.join(resume_data_dir, "work_positions.csv"))
      contents = positions.sort_by { |row| row["order"].to_i }.map do |row|
        topic_titles = WORK_RESEARCH_TOPICS_BY_POSITION.fetch(row["id"], []).filter_map do |topic_id|
          read_single_value_file(
            resolve_resume_data_file(
              resume_data_dir,
              "research_topics/#{topic_id}/title_en.txt",
              "research_topics/#{topic_id}/title.txt"
            )
          )
        end

        {
          "title" => row["organization_en"].to_s.strip,
          "year" => normalize_period_en(row["period_en"].to_s.empty? ? row["period"] : row["period_en"]),
          "description" => topic_titles.empty? ? nil : topic_titles,
        }
      end

      {
        "title" => "Work Experience",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_research_topics_en(site, resume_data_dir, bibliography)
      research_topic_ids_with_body_en(resume_data_dir).filter_map do |topic_id|
        build_research_topic_en(site, resume_data_dir, bibliography, topic_id)
      end
    end

    def research_topic_ids_with_body_en(resume_data_dir)
      research_topics_dir = resolve_resume_data_file(resume_data_dir, "research_topics", "research")
      return [] if research_topics_dir.nil? || !Dir.exist?(research_topics_dir)

      topic_ids = Dir.children(research_topics_dir).sort.select do |topic_id|
        topic_dir = File.join(research_topics_dir, topic_id)
        next false unless Dir.exist?(topic_dir)

        File.exist?(File.join(topic_dir, "body_en.md"))
      end

      topic_ids.sort_by do |topic_id|
        preferred_index = RESEARCH_TOPIC_ORDER.index(topic_id)
        [topic_id == "dark_matter" ? 1 : 0, preferred_index || RESEARCH_TOPIC_ORDER.length, topic_id]
      end
    end

    def build_research_topic_en(site, resume_data_dir, bibliography, topic_id)
      title = read_single_value_file(
        resolve_resume_data_file(resume_data_dir, "research_topics/#{topic_id}/title_en.txt")
      )
      body_markdown = read_optional_resume_data_file(resume_data_dir, "research_topics/#{topic_id}/body_en.md")
      return nil if title.nil? || body_markdown.nil?

      topic = {
        "id" => topic_id,
        "title" => title,
        "body_markdown" => body_markdown,
      }

      summary = read_single_value_file(
        resolve_resume_data_file(resume_data_dir, "research_topics/#{topic_id}/tldr_en.txt")
      )
      topic["summary"] = summary unless summary.nil? || summary.empty?

      figure_path = resolve_resume_data_file(
        resume_data_dir,
        "research_topics/#{topic_id}/main_en.pdf",
        "research_topics/#{topic_id}/main.pdf",
        "research/#{topic_id}/main_en.pdf",
        "research/#{topic_id}/main.pdf"
      )
      unless figure_path.nil?
        topic["figure_url"] = resume_data_web_path(resume_data_dir, figure_path)
        english_preview = File.basename(figure_path) == "main_en.pdf"
        topic["figure_preview_image_url"] = research_topic_figure_preview_image_url(site, topic_id, english: english_preview)
      end

      publications = build_research_topic_publications_en(bibliography, topic_id)
      topic["publications"] = publications unless publications.nil?

      topic
    end

    def build_research_topic_publications_en(bibliography, topic_id)
      contents = bibliography.each_with_index.filter_map do |entry, index|
        next unless normalize_bibtex_text(bibtex_field(entry, :research_topic)) == topic_id

        keywords = bibtex_keywords(entry)
        next unless keywords.include?("selected")
        next unless international_entry?(entry)
        next if keywords.include?("blog") || keywords.include?("oss")

        build_bibliography_content_en(entry, index)
      end.sort_by { |content| [-content.delete("_sort_year").to_i, content.delete("_sort_index").to_i] }
      return nil if contents.empty?

      {
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def research_topic_figure_preview_image_url(site, topic_id, english: false)
      preview_candidates = []
      preview_candidates << "#{topic_id}_en.png" if english
      preview_candidates << "#{topic_id}.png"

      preview_candidates.each do |filename|
        absolute_path = File.join(site.source, "assets", "img", "research_topics", filename)
        next unless File.exist?(absolute_path)

        return File.join("/assets/img/research_topics", filename)
      end

      nil
    end

    def build_publications_section_en(bibliography)
      contents = [
        build_bibliography_subsection_en("Journal Articles", bibliography, label: "journal", international_only: true, badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_subsection_en("International Conferences", bibliography, label: "international-conference", international_only: true, badge_fields: %i[tag abbr], include_authors: true),
      ].compact
      return nil if contents.empty?

      {
        "title" => "Publications and Presentations",
        "type" => "subsections",
        "contents" => contents,
      }
    end

    def build_selected_achievements_en(bibliography)
      [
        build_bibliography_time_table_en("Journal Articles", bibliography, label: "journal", selected: true, international_only: true, badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_time_table_en("International Conferences", bibliography, label: "international-conference", selected: true, international_only: true, badge_fields: %i[tag abbr], include_authors: true),
      ].compact
    end

    def build_bibliography_subsection_en(title, bibliography, label:, selected: false, international_only: false, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      contents = build_bibliography_contents_en(
        bibliography,
        label: label,
        selected: selected,
        international_only: international_only,
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

    def build_bibliography_time_table_en(title, bibliography, label:, selected: false, international_only: false, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      contents = build_bibliography_contents_en(
        bibliography,
        label: label,
        selected: selected,
        international_only: international_only,
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

    def build_bibliography_contents_en(bibliography, label:, selected: false, international_only: false, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      bibliography.each_with_index.filter_map do |entry, index|
        next unless bibliography_entry_match?(entry, label, selected: selected, international_only: international_only)

        build_bibliography_content_en(
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

    def build_bibliography_content_en(entry, index, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      title = normalize_bibtex_text(bibtex_field(entry, :title))
      return nil if title.empty?

      badge = normalize_bibtex_text(bibtex_field(entry, *badge_fields))
      badge = fallback_badge.to_s.strip if badge.empty? && fallback_badge
      badge = translate_bibliography_badge_en(badge)

      institution = normalize_bibtex_text(
        bibtex_field(entry, :journaltitle, :journal, :booktitle, :publisher, :howpublished, :organization, :abbr)
      )
      institution = fallback_institution.to_s.strip if institution.empty? && fallback_institution
      institution = "" if !badge.empty? && institution == badge

      url = normalize_bibtex_text(bibtex_field(entry, :url))
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
      content["institution_url"] = url unless url.empty?
      institution_meta_html = bibliography_institution_meta_html_en(entry)
      content["institution_meta_html"] = institution_meta_html unless institution_meta_html.empty?
      authors = bibliography_authors_html(entry)
      content["authors_html"] = authors if include_authors && !authors.empty?
      content
    end

    def bibliography_institution_meta_html_en(entry)
      fragments = []
      note = translate_note_en(normalize_bibtex_text(bibtex_field(entry, :note)))
      acceptance_rate = normalize_bibtex_text(bibtex_field(entry, :acceptance_rate, :usera))

      fragments << %(<span class="cv-time-inline-meta cv-time-inline-note">; #{note}</span>) unless note.empty?
      fragments << %(<span class="cv-time-inline-meta cv-time-inline-acceptance">; acceptance rate: #{acceptance_rate}</span>) unless acceptance_rate.empty?
      fragments.join(" ")
    end

    def bibliography_entry_match?(entry, label, selected: false, international_only: false)
      keywords = bibtex_keywords(entry)
      return false if selected && !keywords.include?("selected")
      return false if international_only && !international_entry?(entry)

      case label
      when "journal"
        keywords.include?("journal")
      when "international-conference"
        international_entry?(entry) && !keywords.include?("journal") && !keywords.include?("talk")
      when "invited-talk"
        keywords.include?("talk")
      else
        false
      end
    end

    def translate_bibliography_badge_en(badge)
      BIB_BADGE_EN.fetch(badge.to_s.strip, badge.to_s.strip)
    end

    def translate_note_en(note)
      NOTE_EN.fetch(note.to_s.strip, note.to_s.strip)
    end
  end
end
