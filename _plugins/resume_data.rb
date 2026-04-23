require "csv"
require "cgi"
require "bibtex"
require "fileutils"

module Jekyll
  class ResumeDataGenerator < Generator
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
      local_sections = Array(site.data["cv_ja_local"]).reject { |section| section["title"] == "招待講演" }
      [
        build_education_section(resume_data_dir),
        build_work_section(resume_data_dir),
        build_awards_section(resume_data_dir),
        build_invited_talks_section(resume_data_dir),
        *local_sections,
        build_academic_service_section(site, resume_data_dir),
      ].compact
    end

    def read_csv(path)
      CSV.read(path, headers: true).map(&:to_h)
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

    def build_awards_section(resume_data_dir)
      rows = read_csv(File.join(resume_data_dir, "awards.csv"))
      contents = rows.map do |row|
        award_title = row["award"].to_s.strip
        {
          "title" => award_title,
          "institution" => row["event"],
          "year" => row["year"].to_s.strip,
          "emphasize_title" => award_title.include?("(主著)"),
          "normal_weight_title" => true,
        }
      end

      {
        "title" => "受賞",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_invited_talks_section(resume_data_dir)
      bibliography = BibTeX.parse(File.read(File.join(resume_data_dir, "publications.bib")))
      contents = bibliography.each_with_object([]) do |entry, talks|
        next unless bibtex_keywords(entry).include?("talk")

        display_text = compact_strings([bibtex_field(entry, :title), bibtex_field(entry, :booktitle)]).join(", ")
        next if display_text.empty?

        talks << {
          "title" => linked_title(display_text, bibtex_field(entry, :url)),
          "year" => bibtex_field(entry, :year),
          "normal_weight_title" => true,
        }
      end

      return nil if contents.empty?

      {
        "title" => "招待講演",
        "type" => "time_table",
        "contents" => contents,
      }
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

    def linked_title(text, url)
      return text if url.empty?

      %(#{CGI.escapeHTML(text)} <a href="#{CGI.escapeHTML(url)}" target="_blank" rel="noopener noreferrer">[link]</a>)
    end
  end
end
