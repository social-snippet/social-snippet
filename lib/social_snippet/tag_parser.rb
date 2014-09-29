module SocialSnippet
  class TagParser
    class << self

      # Find `@snip` tags from text
      #
      # @param s [String or Array] parsed text
      # @return [Array] found `@snip` tags with line_no
      def find_snip_tags(s)
        found_lines = []

        lines = get_lines(s)

        lines.each.with_index do |line, i|
          if Tag.is_snip_tag_line(line)
            found_lines.push(
              {
                :line_no => i,
                :tag => Tag.new(line),
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
          if Tag.is_snippet_tag_line(line)
            found_lines.push(
              {
                :line_no => i,
                :tag => Tag.new(line),
              }
            )
          end
        end

        return found_lines
      end

      def get_lines(s)
        if s.is_a?(String)
          return s.split("\n")
        elsif s.is_a?(Array)
          return s
        end
      end

    end

  end
end
