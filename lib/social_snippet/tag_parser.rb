module SocialSnippet

  class TagParser

    class << self

      # Find `@snip` tags from text
      #
      # @param s [String or Array] parsed text
      # @return [Array] found `@snip` tags with line_no
      def find_snip_tags(s)
        find_lines(s) {|line| Tag.is_snip_tag_line(line) }
      end

      # Find `@snippet` tags from text
      #
      # @param s [String or Array] parsed text
      # @return [Array] found `@snippet` tags with line_no
      def find_snippet_tags(s)
        find_lines(s) {|line| Tag.is_snippet_tag_line(line) }
      end

      def find_no_tags(s)
        find_lines(s) {|line| Tag.is_no_tag_line?(line) }
      end

      private

      def find_lines(s, &comparator)
        get_lines(s).each.with_index.inject([]) do |found_lines, (line, i)|
          if comparator.call(line)
            found_lines.push(
              {
                :line_no => i,
                :tag => Tag.new(line),
              }
            )
          end
          found_lines
        end
      end

      def get_lines(s)
        if s.is_a?(::String)
          s.split($/)
        elsif s.is_a?(::Array)
          s
        elsif s.is_a?(::Enumerator)
          s
        else
          raise "error unknown data"
        end
      end

    end

  end

end

