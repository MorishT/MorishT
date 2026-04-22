require "csv"
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
      local_sections = Array(site.data["cv_ja_local"])
      [
        build_education_section(resume_data_dir),
        build_work_section(resume_data_dir),
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

    def build_academic_service_section(site, resume_data_dir)
      rows = read_csv(File.join(resume_data_dir, "academic_service.csv"))
      contents = []

      memberships = Array(site.data.dig("resume_overrides", "academic_service_memberships"))
      unless memberships.empty?
        contents << {
          "title" => "所属学会",
          "items" => memberships,
        }
      end

      rows.sort_by { |row| row["order"].to_i }.each do |row|
        items = compact_strings(row["summary"].to_s.split(/\s*\/\s*/))
        contents << {
          "title" => row["title"],
          "items" => items,
        }
      end

      {
        "title" => "学術貢献活動",
        "type" => "nested_list",
        "contents" => contents,
      }
    end
  end
end
