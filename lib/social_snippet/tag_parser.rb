module SocialSnippet
  class TagParser
    # Find `@snip` tags from text
    #
    # @param s [String] parsed text
    # @return [Array] found `@snip` tags with line_no
    def find_snip_tags(s)
      found_lines = []
      s.split("\n").each.with_index do |line, i|
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

  end
end
