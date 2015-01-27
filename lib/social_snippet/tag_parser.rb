class SocialSnippet::TagParser

  class << self

    # Find `@snip` tags from text
    #
    # @param s [String or Array] parsed text
    # @return [Array] found `@snip` tags with line_no
    def find_snip_tags(s)
      found_lines = []

      lines = get_lines(s)

      lines.each.with_index do |line, i|
        if ::SocialSnippet::Tag.is_snip_tag_line(line)
          found_lines.push(
            {
              :line_no => i,
              :tag => ::SocialSnippet::Tag.new(line),
            }
          )
        end
      end

      return found_lines
    end

    # Find `@snippet` tags from text
    #
    # @param s [String or Array] parsed text
    # @return [Array] found `@snippet` tags with line_no
    def find_snippet_tags(s)
      found_lines = []

      lines = get_lines(s)

      lines.each.with_index do |line, i|
        if ::SocialSnippet::Tag.is_snippet_tag_line(line)
          found_lines.push(
            {
              :line_no => i,
              :tag => ::SocialSnippet::Tag.new(line),
            }
          )
        end
      end

      return found_lines
    end

    def get_lines(s)
      if s.is_a?(String)
        s.split($/)
      elsif s.is_a?(Array)
        s
      elsif s.is_a?(Enumerator)
        s
      else
        raise "error unknown data"
      end
    end

  end

end
