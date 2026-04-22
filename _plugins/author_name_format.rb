module Jekyll
  module AuthorNameFormat
    CJK_REGEX = /[\p{Han}\p{Hiragana}\p{Katakana}]/

    def format_author_name(first_name, last_name)
      first = first_name.to_s.strip
      last = last_name.to_s.strip
      return first if last.empty?
      return last if first.empty?

      if cjk_name?(first) || cjk_name?(last)
        "#{last} #{first}"
      else
        "#{first} #{last}"
      end
    end

    private

    def cjk_name?(name)
      CJK_REGEX.match?(name.to_s)
    end
  end
end

Liquid::Template.register_filter(Jekyll::AuthorNameFormat)
