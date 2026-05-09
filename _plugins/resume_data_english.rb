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

    ABOUT_EN_MARKDOWN = <<~MD
      A researcher at Hitachi's Central Research Laboratory.

      My primary research area is natural language processing, while I also work on neighboring areas such as machine learning and economics x AI:
      * Natural language processing: automatic generation of logical reasoning corpora for improving the reasoning capabilities of LLMs
      * Machine learning: theoretical clarification of the fundamental factors that determine ensemble performance
      * Economics x AI: macroeconomic simulation with many LLM agents

      Alongside practical industrial research at the company, I pursue these more fundamental research themes.

      At university, I worked on physics, especially particle physics and astroparticle physics.

      I am interested in uncovering the universal principles behind phenomena.
      That means the principles of nature in physics, the principles of thought in symbolic logic (logical reasoning), and the principles behind economic phenomena in economics.
    MD

    RESEARCH_INTERESTS_EN = [
      "Natural language processing: automatic generation of logical reasoning corpora for improving the reasoning capabilities of LLMs",
      "Machine learning: theoretical clarification of the fundamental factors that determine ensemble performance",
      "Economics x AI: macroeconomic simulation with many LLM agents",
    ].freeze

    EDUCATION_DEGREE_EN = {
      "博士(工学)" => "Ph.D. in Engineering",
      "修士(理学)" => "Master of Science",
      "学士(理学)" => "Bachelor of Science",
    }.freeze

    EDUCATION_INSTITUTION_EN = {
      "筑波大学大学院 知能機能システム学位プログラム（社会人早期修了コース）" => "Doctoral Program in Intelligent and Mechanical Interaction Systems, University of Tsukuba (Early Graduation Program for Working Professionals)",
      "東京大学大学院 理学系研究科 物理学専攻" => "Department of Physics, Graduate School of Science, The University of Tokyo",
      "東京大学 理学部 物理学科" => "Department of Physics, Faculty of Science, The University of Tokyo",
    }.freeze

    EDUCATION_FIELD_EN = {
      "自然言語処理" => "natural language processing",
      "素粒子・宇宙物理学" => "particle physics and astroparticle physics",
    }.freeze

    EDUCATION_ADVISOR_EN = {
      "宇津呂 武仁 教授" => "Prof. Takehito Utsuro",
      "村山 斉 教授" => "Prof. Hitoshi Murayama",
      "横山 将志 教授" => "Prof. Masashi Yokoyama",
    }.freeze

    EDUCATION_THESIS_EN = {
      "博士論文: 大規模言語モデルの推論能力改善手法に関する研究" => "Dissertation title: Research on methods for improving the reasoning capabilities of large language models",
      "修士論文: Constraints on Wino Dark Matter from the Milky Way Galaxy (天の川銀河からの光観測データを用いた暗黒物質の探求)" => "Master's thesis: Constraints on Wino Dark Matter from the Milky Way Galaxy",
    }.freeze

    WORK_ORGANIZATION_EN = {
      "日立製作所 中央研究所 - 研究員" => "Hitachi, Ltd. Central Research Laboratory - Researcher",
      "東芝 研究開発センター - 研究員" => "Toshiba Corporation R&D Center - Researcher",
    }.freeze

    RESEARCH_TOPIC_TITLE_EN = {
      "FLD" => "Automatic generation of logical reasoning corpora for improving LLM reasoning",
      "ensemble" => "A fundamental theory of ensemble learning",
      "competition" => "Participation in international NLP competitions",
      "economic_simulation" => "Large-scale macroeconomic simulation with LLM agents",
      "NLP_applications" => "Development of practical systems using natural language processing",
      "speech_recognition" => "Practical deployment of speech recognition engines with deep learning",
      "dark_matter" => "Exploring the origin of dark matter with the wino predicted by supersymmetry",
      "debate" => "A decision-support application for collecting and organizing information from business perspectives",
    }.freeze

    RESEARCH_TOPIC_TRANSLATIONS = {
      "FLD" => {
        "title" => "Automatic generation of logical reasoning corpora for improving LLM reasoning",
        "summary" => "We proposed design principles for logical reasoning examples based on symbolic logic, developed an automatic generation algorithm, and substantially improved LLM reasoning through large-scale training.",
        "body_markdown" => <<~MD.strip,
          The ability to follow logic step by step is one of the foundations of human intellectual activity.
          Large language models can generate natural text from enormous amounts of knowledge, but are they truly reasoning in a logically correct way?

          We study how to teach logical reasoning to LLMs.
          As a starting point, we organized the characteristics of logical reasoning by drawing on insights from symbolic logic and related fields.
          In logical reasoning, new facts are derived by applying inference rules, for example deriving `B` from the facts `A` and `if A then B`.
          There are many kinds of such rules, but they can be derived from a small set of more fundamental rules.

          Based on this view, we designed **logical reasoning problems for LLMs**.
          Starting from given facts, the model applies fundamental inference rules one step at a time until it reaches the final answer.
          By instantiating `A` and `B` with many different facts, the model can also learn the generality of the rules themselves.
          We then developed an **automatic generation algorithm** that can produce large numbers of such problems.
          It first constructs the skeleton of a problem by stacking inference rules over multiple steps, and then generates concrete facts using vocabularies and natural-language templates.

          Training LLMs on the generated problems led to large improvements on logical reasoning tasks.
          We also observed gains on broader reasoning tasks such as mathematics, science, and coding.
          We believe this happens because logical reasoning forms a foundation for many kinds of reasoning.

          This project has continued from around 2022 to the present.
          In addition to training data, we are also developing benchmarks for evaluating the logical reasoning ability of LLMs.
          Our goal is not merely plausible answers, but genuinely correct reasoning.
        MD
      },
      "competition" => {
        "title" => "Participation in international NLP competitions",
        "summary" => "We participated in SemEval and CoNLL, two leading international NLP competitions, and won first place in multiple tasks on intent analysis and semantic parsing.",
        "body_markdown" => <<~MD.strip,
          With the rise of social media, the internet is now filled with posts written with a wide range of intentions.
          Technologies for analyzing the intentions embedded in such posts are increasingly important for building healthy and safe online spaces.

          We participated in multiple tasks in the international competition **SemEval 2020**, which featured problems on intention analysis.
          One example was a task where a language model had to assess how funny an edited news headline was.

          Our approach started by extending state-of-the-art language models with task-specific architectures.
          For the humor task above, we fed both the original and edited sentences into the model and let an added cross-attention layer compare and analyze them.
          We then built ensembles of multiple models according to our own recipe and achieved high accuracy.
          As a result, we won **first place in multiple tasks**.

          Accurate intention analysis also requires understanding the semantic structure of sentences.
          We therefore participated in **CoNLL 2020 Shared Task**, which focused on semantic structure parsing, and won first place there as well.

          These experiences later deepened our interest in ensemble learning and led to one of our subsequent research themes.
        MD
      },
      "economic_simulation" => {
        "title" => "Large-scale macroeconomic simulation with LLM agents",
        "summary" => "We modeled human behavior with 100 LLM agents and simulated 25 years within a dynamic environment grounded in economic theory.",
        "body_markdown" => <<~MD.strip,
          In recent years, AI has advanced rapidly and has been widely adopted in natural sciences such as physics and mathematics.
          In the social sciences, however, the use of AI is still at an early stage.

          **Economics** is one of the most influential fields in the social sciences.
          It has sought to explain economic phenomena in order to make human society more prosperous.
          Traditionally, it has relied mainly on theoretical approaches: one introduces mathematical assumptions about human behavior and then deduces the consequences.

          To understand economic phenomena more deeply, experiments are also important.
          Yet experimenting on real human society faces ethical constraints and high costs.
          For this reason, economics has often been regarded as a field where experimentation is difficult.

          We aim to overcome this limitation by **simulating economic phenomena on computers**.
          Using large language models, we model the behavior of individual people and firms, and analyze the economic phenomena that emerge from their interactions.
          Concretely, we modeled consumers and firms with 100 LLM agents and let them interact within a dynamic environment based on an economic theory that we designed.
          We confirmed that well-known economic phenomena such as **economic growth** and **international trade** emerged from the simulation.

          We also tested a scenario in which **a civilization-ending asteroid approaches Earth**.
          In that setting, people abandoned work to spend their final days with loved ones, while firms gave up long-term strategies such as investment and R&D.
          As a result, we observed the collapse of the economy as a whole.
        MD
      },
      "ensemble" => {
        "title" => "A fundamental theory of ensemble learning",
        "summary" => "We clarified the fundamental factors that determine ensemble performance by decomposing the lower bound of ensemble error into three components using information theory.",
        "body_markdown" => <<~MD.strip,
          Ensemble learning combines the predictions of multiple models to achieve higher accuracy.
          Because it is simple and powerful, it has become one of the most popular techniques in machine learning.
          A large number of methods have been proposed over the years.

          Even so, ensemble learning has long contained a fundamental mystery:
          **what determines the performance of an ensemble?**
          Answering this question is essential for designing better methods.

          We succeeded in clarifying this mystery.
          We showed that ensemble performance is determined by three elements:
          **the accuracy of each individual model, the diversity among models, and the information loss that occurs when combining their predictions (fusion loss).**

          High individual accuracy is of course important.
          Diversity among models is also valuable because one model can correct the mistakes of another.
          Yet when multiple predictions are combined, correct signals can be buried under incorrect ones.
          In such cases the information loss becomes large, and the full potential of the ensemble cannot be realized.

          To analyze this problem, we focused on **Fano's inequality** from information theory.
          Fano's inequality provides a lower bound on the error rate when reconstructing information from noisy observations.
          In the ensemble setting, it can be interpreted as a lower bound on the error rate of an ensemble method, that is, a barometer of ensemble performance.
          We proved mathematically that this lower bound can be decomposed into the three factors above.

          We are further computing these factors for a range of ensemble methods in order to analyze which methods improve which components.

          This project was motivated by our experience of achieving strong results with ensemble methods in international NLP competitions such as SemEval and CoNLL.
        MD
      },
      "dark_matter" => {
        "title" => "Exploring the origin of dark matter with the wino predicted by supersymmetry",
        "body_markdown" => <<~MD.strip,
          The universe is believed to contain a large amount of **dark matter**, which cannot be seen directly with light.
          Its true nature is still unknown, making it one of the biggest mysteries in modern physics.

          In this work, we focused on the **wino**, a particle predicted by **supersymmetry**, as a candidate for dark matter.
          If the wino constitutes dark matter, wino pairs near the center of the Milky Way may annihilate and emit gamma rays, which are high-energy electromagnetic waves.

          The strength and spatial distribution of such gamma rays depend strongly on how dark matter itself is distributed near the Galactic center.

          We therefore estimated that spatial distribution using a range of astrophysical observations.
          By combining the inferred distribution with gamma-ray observations, we examined whether the wino is a plausible dark-matter candidate.

          We found that, within the range allowed by currently available observations, **the wino remains a viable dark-matter candidate**.
        MD
      },
      "debate" => {
        "title" => "A decision-support application for collecting and organizing information from business perspectives",
        "body_markdown" => <<~MD.strip,
          "Should our company invest in thermal power generation projects in Africa?"
          Sound business decisions require collecting and organizing information from perspectives that directly matter to the decision itself.
          Examples include questions such as "Is there demand for thermal power in Africa?" and "Have competitors already entered that market?"

          We developed a decision-support application that helps users collect and organize information along such decision-oriented perspectives.
          The core technology of the system is **relation extraction**, which identifies important relations expressed in text.
          Concretely, it analyzes business-relevant relations such as "A has demand for B" or "A enters B" by using syntactic analysis.
          By applying this technology to large amounts of text data, the system makes it possible to gather and organize information from business perspectives and use it for decision making.
        MD
      },
    }

    BIB_TITLE_EN = {
      "morishita_2026_NLP_journal_keynote" => "An approach using an artificial logical reasoning corpus to teach reasoning to large language models",
      "morishita_2025_YANS_corporate_research" => "Working in a corporate research lab (and a path toward doing research freely)",
      "morishita_2025_IBIS_logic_rl" => "Constructing artificial corpora based on mathematical logic and improving LLM reasoning through reinforcement learning",
      "morishita_2025_JNLP_FLD_diverse" => "An approach using an artificial logical reasoning corpus to teach reasoning to large language models",
      "morishita_2025_JSAI_econ_growth_agent" => "EconGrowthAgent: Macroeconomic simulation based on LLM agents and economic growth theory",
      "morishita_2026_JSAI_econ_trade_agent" => "EconTradeAgent: Macroeconomic simulation based on LLM agents and international trade theory",
      "morishita_2024_NLP_colloquium_FLD_diverse" => "Can LLMs be taught logical reasoning? An approach using artificial corpora",
      "morishita_2024_IBIS_ensemble" => "Toward a fundamental theory of ensemble learning",
      "morishita_2024_JSAI_FLD_diverse" => "Improving general logical reasoning in LLMs with inductively diversified large-scale logical reasoning corpora",
      "morishita_2024_NLP_JFLD" => "Proposing JFLD: a Japanese logical reasoning benchmark",
      "morishita_2023_JSAI_ensemble" => "Toward a fundamental theory of ensemble learning",
      "morishita_2023_JSAI_FLD" => "How does learning from artificial deductive reasoning corpora strengthen language models?",
      "koreeda_2023_JSAI_readme" => "README generation based on large language models and heuristics",
      "sasazawa_2023_NLP_keword" => "Controlling keyword positions in text generation",
      "morishita_2023_NLP_FLD" => "Instilling deductive reasoning into language models using deductive corpora based on formal logic",
      "morishita_2022_JSAI_RL" => "Introducing long-term planning into sequence-modeling reinforcement learning via future-trajectory prediction",
      "oazaki2020meeting" => "A topic estimation method for utterances and a meeting-support system using predicate-argument structure analysis and distributed representations",
      "morishita_2019_JSAI_decision_support" => "AI for business strategy support based on case retrieval and investigation-theme recommendation",
      "media_2024_press_logic_corpus" => "Developed a core technology for automatically generating training data that strengthens the logical thinking ability of generative AI",
      "media_2024_nikkei_robotics_corpus" => "Hitachi significantly improves logical reasoning in language models with automated corpus generation",
      "media_2023_nikkei_robotics_ensemble" => "How can ensemble learning be improved? Hitachi proposes a new theory useful for practice",
      "media_2020_press_sota_competitions" => "Won first place in multiple tracks of the international NLP competitions CoNLL 2020 Shared Task and SemEval 2020",
      "media_2018_nikkei_working_ai" => "Working AI: your colleague is AI, and it can even read your mind",
    }.freeze

    BIB_BADGE_EN = {
      "言語処理学会" => "NLP",
      "人工知能学会" => "JSAI",
      "NLPコロキウム" => "NLP Colloquium",
      "自然言語処理 (最優秀論文賞)" => "JNLP (Best Paper)",
      "人工知能学会 (優秀賞)" => "JSAI (Excellent Award)",
      "ICML (Spotlight=上位5%)" => "ICML (Spotlight)",
      "SemEval (1位)" => "SemEval (1st)",
      "SemEval (1位, Oral)" => "SemEval (1st, Oral)",
      "SemEval (2位)" => "SemEval (2nd)",
      "CoNLL (1位)" => "CoNLL (1st)",
      "最優秀論文賞" => "Best Paper",
      "優秀賞" => "Excellent Award",
      "コンペ１位" => "1st",
      "コンペ２位" => "2nd",
      "プレス" => "Press",
      "ブログ" => "Blog",
    }.freeze

    BIB_INSTITUTION_EN = {
      "言語処理学会 論文賞招待セッション" => "Invited best-paper session, Association for Natural Language Processing",
      "NLP若手の会 招待ポスター" => "Invited poster, Young Researchers' Symposium on NLP",
      "NLPコロキウム 12/04" => "NLP Colloquium (Dec. 4)",
      "『自然言語処理』" => "Journal of Natural Language Processing",
      "一般社団法人 人工知能学会" => "Japanese Society for Artificial Intelligence",
      "日立製作所 プレスリリース" => "Hitachi press release",
      "日経ロボティクス取材記事 (2024年1月号)" => "Nikkei Robotics feature article (January 2024 issue)",
      "日経ロボティクス取材記事 (2023年2月号)" => "Nikkei Robotics feature article (February 2023 issue)",
      "日本経済新聞" => "Nikkei",
      "ブログ" => "Blog",
    }.freeze

    NOTE_EN = {
      "最優秀論文賞" => "Best Paper Award",
      "優秀賞" => "Excellent Presentation Award",
      "Spotlight (上位5%)" => "Spotlight (top 5%)",
      "1位" => "1st place",
      "2位" => "2nd place",
      "Oral, 1位" => "Oral, 1st place",
    }.freeze

    AWARD_EVENT_EN = {
      "FT-LLM 2026 チューニングコンペティション 数学タスク部門" => "FT-LLM 2026 Tuning Competition, Mathematics Track",
      "言語処理学会論文誌「自然言語処理」 2025年度" => "Journal of Natural Language Processing, 2025",
      "人工知能学会全国大会 第39回" => "39th Annual Conference of the Japanese Society for Artificial Intelligence",
      "人工知能学会全国大会 第37回" => "37th Annual Conference of the Japanese Society for Artificial Intelligence",
    }.freeze

    AWARD_TEXT_EN = {
      "1位 (共著)" => "1st place (coauthor)",
      "最優秀論文賞 (主著)" => "Best Paper Award (lead author)",
      "優秀賞 (主著)" => "Excellent Award (lead author)",
      "優秀賞 (共著)" => "Excellent Award (coauthor)",
      "Spotlight (上位5\\%) (主著)" => "Spotlight (top 5%) (lead author)",
      "1位 (主著)" => "1st place (lead author)",
      "2位 (主著)" => "2nd place (lead author)",
      "2位 (共著)" => "2nd place (coauthor)",
    }.freeze

    AWARD_BADGE_EN = {
      "コンペ１位" => "1st",
      "コンペ２位" => "2nd",
      "最優秀論文賞" => "Best Paper",
      "優秀賞" => "Excellent Award",
      "Spotlight" => "Spotlight",
    }.freeze

    ACADEMIC_SERVICE_EN = {
      "学会運営" => {
        "title" => "Organization",
        "items" => [
          "Area Chair of ACL Rolling Review",
          "Organizer of the NLP 2026 theme session: \"Mathematical NLP in the Era of Large Language Models: Practical Foundations for Representation, Reasoning, and Verification\"",
        ],
      },
      "査読経験" => {
        "title" => "Reviewing",
        "text" => "NeurIPS / ICML / ICLR / ACL / EMNLP / EACL / COLING / LREC",
      },
    }.freeze

    def generate(site)
      resume_data_dir = File.join(site.source, "resume", "data")
      return unless Dir.exist?(resume_data_dir)

      bibliography_path = File.join(resume_data_dir, "publications.bib")
      return unless File.exist?(bibliography_path)

      bibliography = BibTeX.parse(File.read(bibliography_path))

      site.data["resume"] ||= {}
      site.data["resume"]["about_en"] = ABOUT_EN_MARKDOWN
      site.data["resume"]["cv_en"] = build_cv_en(resume_data_dir, bibliography)
      site.data["resume"]["selected_achievements_en"] = build_selected_achievements_en(bibliography)
      site.data["resume"]["research_topics_en"] = build_research_topics_en(resume_data_dir, bibliography)
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

    def csv_truthy?(value)
      %w[1 true yes y].include?(value.to_s.strip.downcase)
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

    def bibtex_key(entry)
      entry.key.to_s
    end

    def ordinalize(number)
      value = number.to_i
      abs = value.abs
      suffix =
        if (11..13).cover?(abs % 100)
          "th"
        else
          { 1 => "st", 2 => "nd", 3 => "rd" }[abs % 10] || "th"
        end
      "#{value}#{suffix}"
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
        build_research_section_en,
        build_education_section_en(resume_data_dir),
        build_work_section_en(resume_data_dir),
        build_publications_section_en(bibliography),
        build_invited_talks_section_en(bibliography),
        build_press_section_en(bibliography),
        build_oss_section_en(bibliography),
        build_awards_section_en(resume_data_dir),
        build_academic_service_section_en(resume_data_dir),
      ].compact
    end

    def build_research_section_en
      {
        "title" => "Research Interests",
        "type" => "list",
        "contents" => RESEARCH_INTERESTS_EN,
      }
    end

    def build_education_section_en(resume_data_dir)
      rows = read_csv(File.join(resume_data_dir, "education.csv"))
      contents = rows.sort_by { |row| row["order"].to_i }.map do |row|
        field = EDUCATION_FIELD_EN[row["field"].to_s.strip]
        advisor = EDUCATION_ADVISOR_EN[row["advisor"].to_s.strip]
        thesis = EDUCATION_THESIS_EN[row["thesis"].to_s.strip]

        description = compact_strings(
          [
            ("Research theme: #{field}" unless field.to_s.empty?),
            thesis,
            ("Supervisor: #{advisor}" unless advisor.to_s.empty?),
          ]
        )

        {
          "title" => EDUCATION_DEGREE_EN.fetch(row["degree"].to_s.strip, row["degree"].to_s.strip),
          "institution" => EDUCATION_INSTITUTION_EN.fetch(row["institution"].to_s.strip, row["institution"].to_s.strip),
          "year" => normalize_period_en(row["period"]),
          "match_title_weight_institution" => csv_truthy?(row["match_title_weight_institution"]),
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
          RESEARCH_TOPIC_TITLE_EN[topic_id]
        end

        {
          "title" => WORK_ORGANIZATION_EN.fetch(row["organization"].to_s.strip, row["organization"].to_s.strip),
          "year" => normalize_period_en(row["period"]),
          "description" => topic_titles.empty? ? nil : topic_titles,
        }
      end

      {
        "title" => "Work Experience",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_research_topics_en(resume_data_dir, bibliography)
      research_topic_ids_with_body(resume_data_dir).filter_map do |topic_id|
        build_research_topic_en(resume_data_dir, bibliography, topic_id)
      end
    end

    def research_topic_ids_with_body(resume_data_dir)
      research_topics_dir = resolve_resume_data_file(resume_data_dir, "research_topics", "research")
      return [] if research_topics_dir.nil? || !Dir.exist?(research_topics_dir)

      topic_ids = Dir.children(research_topics_dir).sort.select do |topic_id|
        topic_dir = File.join(research_topics_dir, topic_id)
        next false unless Dir.exist?(topic_dir)

        File.exist?(File.join(topic_dir, "body.md")) || File.exist?(File.join(topic_dir, "body.tex"))
      end

      topic_ids.sort_by do |topic_id|
        preferred_index = RESEARCH_TOPIC_ORDER.index(topic_id)
        [topic_id == "dark_matter" ? 1 : 0, preferred_index || RESEARCH_TOPIC_ORDER.length, topic_id]
      end
    end

    def build_research_topic_en(resume_data_dir, bibliography, topic_id)
      translation = RESEARCH_TOPIC_TRANSLATIONS[topic_id]
      return nil if translation.nil?

      figure_path = resolve_resume_data_file(
        resume_data_dir,
        "research_topics/#{topic_id}/main.pdf",
        "research/#{topic_id}/main.pdf"
      )

      topic = {
        "id" => topic_id,
        "title" => translation["title"],
        "body_markdown" => translation["body_markdown"],
      }
      topic["summary"] = translation["summary"] if translation["summary"]
      topic["figure_url"] = resume_data_web_path(resume_data_dir, figure_path) unless figure_path.nil?

      publications = build_research_topic_publications_en(bibliography, topic_id)
      topic["publications"] = publications unless publications.nil?

      topic
    end

    def build_research_topic_publications_en(bibliography, topic_id)
      contents = bibliography.each_with_index.filter_map do |entry, index|
        next unless normalize_bibtex_text(bibtex_field(entry, :research_topic)) == topic_id

        keywords = bibtex_keywords(entry)
        next unless keywords.include?("selected")
        next if keywords.include?("blog") || keywords.include?("oss")

        build_bibliography_content_en(entry, index)
      end.sort_by { |content| [-content.delete("_sort_year").to_i, content.delete("_sort_index").to_i] }

      return nil if contents.empty?

      {
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_publications_section_en(bibliography)
      contents = [
        build_bibliography_subsection_en("Journal Articles", bibliography, label: "journal", badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_subsection_en("International Conferences", bibliography, label: "international-conference", badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_subsection_en("Domestic Conferences", bibliography, label: "domestic-conference", badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_subsection_en("Tech Blog", bibliography, label: "blog", badge_fields: %i[tag abbr], fallback_badge: "Blog", fallback_institution: "Blog", include_authors: true),
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
        build_bibliography_time_table_en("Journal Articles", bibliography, label: "journal", selected: true, badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_time_table_en("International Conferences", bibliography, label: "international-conference", selected: true, badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_time_table_en("Domestic Conferences", bibliography, label: "domestic-conference", selected: true, badge_fields: %i[tag abbr], include_authors: true),
        build_bibliography_time_table_en("Invited Talks", bibliography, label: "invited-talk", selected: true, badge_fields: %i[tag abbr], badge_theme: "purple"),
      ].compact
    end

    def build_awards_section_en(resume_data_dir, selected: false)
      rows = read_csv(File.join(resume_data_dir, "awards.csv"))
      contents = rows.filter_map do |row|
        next if selected && !csv_truthy?(row["selected"])

        award_text = row["award"].to_s.strip
        award_tag = row["tag"].to_s.strip
        {
          "title" => translate_award_event_en(row["event"].to_s.strip),
          "institution" => translate_award_text_en(award_text),
          "year" => row["year"].to_s.strip.gsub("\\%", "%"),
          "badge" => translate_award_badge_en(award_tag),
          "badge_theme" => award_tag.empty? ? nil : "purple",
          "match_title_weight" => true,
          "emphasize_institution" => award_text.include?("(主著)"),
          "normal_weight_institution" => true,
          "normal_weight_title" => true,
        }
      end

      return nil if contents.empty?

      {
        "title" => "Awards",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_invited_talks_section_en(bibliography)
      build_bibliography_time_table_en("Invited Talks", bibliography, label: "invited-talk", badge_fields: %i[tag abbr], badge_theme: "purple")
    end

    def build_press_section_en(bibliography)
      build_bibliography_time_table_en("Press Releases and Media", bibliography, label: "press", badge_fields: %i[tag abbr], fallback_badge: "Press")
    end

    def build_oss_section_en(bibliography)
      contents = build_bibliography_contents_en(
        bibliography,
        label: "oss",
        badge_fields: %i[tag abbr],
        fallback_badge: "OSS"
      ).map do |content|
        next content unless content["institution"] == "HuggingFace Hub"

        updated_content = content.dup
        updated_content.delete("institution")
        updated_content.delete("underline_institution")
        updated_content
      end

      return nil if contents.empty?

      {
        "title" => "OSS",
        "type" => "time_table",
        "contents" => contents,
      }
    end

    def build_academic_service_section_en(resume_data_dir)
      rows = read_csv(File.join(resume_data_dir, "academic_service.csv"))
      contents = rows.sort_by { |row| row["order"].to_i }.filter_map do |row|
        translation = ACADEMIC_SERVICE_EN[row["title"].to_s.strip]
        next if translation.nil?

        content = {
          "title" => translation["title"],
        }
        content["text"] = translation["text"] if translation["text"]
        content["items"] = translation["items"] if translation["items"]
        content
      end

      {
        "title" => "Academic Service",
        "type" => "nested_list",
        "hide" => true,
        "contents" => contents,
      }
    end

    def build_bibliography_subsection_en(title, bibliography, label:, selected: false, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      contents = build_bibliography_contents_en(
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

    def build_bibliography_time_table_en(title, bibliography, label:, selected: false, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      contents = build_bibliography_contents_en(
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

    def build_bibliography_contents_en(bibliography, label:, selected: false, badge_fields: [], fallback_badge: nil, badge_theme: nil, fallback_institution: nil, include_authors: false)
      bibliography.each_with_index.filter_map do |entry, index|
        next unless bibliography_entry_match?(entry, label, selected: selected)

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
      title = translate_bibliography_title_en(entry)
      return nil if title.empty?

      badge = normalize_bibtex_text(bibtex_field(entry, *badge_fields))
      badge = fallback_badge.to_s.strip if badge.empty? && fallback_badge
      badge = translate_bibliography_badge_en(badge)

      institution = normalize_bibtex_text(
        bibtex_field(entry, :journaltitle, :journal, :booktitle, :publisher, :howpublished, :organization, :abbr)
      )
      institution = fallback_institution.to_s.strip if institution.empty? && fallback_institution
      institution = translate_bibliography_institution_en(institution)
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

      fragments << %(<span class="cv-time-inline-meta cv-time-inline-note">#{note}</span>) unless note.empty?
      fragments << %(<span class="cv-time-inline-meta cv-time-inline-acceptance">Acceptance rate: #{acceptance_rate}</span>) unless acceptance_rate.empty?
      fragments.join(" ")
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

    def translate_bibliography_title_en(entry)
      key = bibtex_key(entry)
      title = normalize_bibtex_text(bibtex_field(entry, :title))
      return "" if title.empty?

      BIB_TITLE_EN.fetch(key, title)
    end

    def translate_bibliography_badge_en(badge)
      BIB_BADGE_EN.fetch(badge.to_s.strip, badge.to_s.strip)
    end

    def translate_bibliography_institution_en(value)
      text = value.to_s.strip
      return "" if text.empty?
      return BIB_INSTITUTION_EN[text] if BIB_INSTITUTION_EN.key?(text)

      case text
      when /\A人工知能学会全国大会論文集 第(\d+)回\z/
        "Proceedings of the #{ordinalize(Regexp.last_match(1))} Annual Conference of the Japanese Society for Artificial Intelligence"
      when /\A人工知能学会全国大会論文集\z/
        "Proceedings of the Annual Conference of the Japanese Society for Artificial Intelligence"
      when /\A人工知能学会全国大会 ランチョンセミナー\z/
        "Luncheon seminar, Annual Conference of the Japanese Society for Artificial Intelligence"
      when /\A言語処理学会 第(\d+)年次大会 発表論文集\z/, /\A言語処理学会 第(\d+)回年次大会 発表論文集\z/
        "Proceedings of the #{ordinalize(Regexp.last_match(1))} Annual Meeting of the Association for Natural Language Processing"
      when /\A情報論的学習理論ワークショップ \(IBIS(\d{4})\)\z/
        "Workshop on Information-Based Induction Sciences (IBIS #{Regexp.last_match(1)})"
      else
        text
      end
    end

    def translate_note_en(note)
      NOTE_EN.fetch(note.to_s.strip, note.to_s.strip)
    end

    def translate_award_event_en(text)
      AWARD_EVENT_EN.fetch(text, text)
    end

    def translate_award_text_en(text)
      AWARD_TEXT_EN.fetch(text, text.gsub("\\%", "%"))
    end

    def translate_award_badge_en(text)
      value = text.to_s.strip
      return nil if value.empty?

      AWARD_BADGE_EN.fetch(value, value)
    end
  end
end
