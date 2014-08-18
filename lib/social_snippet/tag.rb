module SocialSnippet
  class Tag
    # Create instance
    #
    # @param s [String] tag line text
    def initialize(s)
      @path   = Tag.get_path(s)
      @repo   = Tag.get_repo(s)
      @prefix = Tag.get_prefix(s)
      @suffix = Tag.get_suffix(s)
      @spaces = Tag.get_spaces(s)
    end

    class << self

      # Check given line to match @snip tag
      def is_snip_tag_line(s)
        return /@snip\s*<.*?>/.match(s)
      end

      # Check given line to match @snippet tag
      def is_snippet_tag_line(s)
        return /@snippet\s*<.*?>/.match(s)
      end

      # Check given line to match @snip or @snippet tag
      def is_snip_or_snippet_tag_line(s)
        return is_snip_tag_line(s) || is_snippet_tag_line(s)
      end

      # Check given line to match `:` character
      def has_colon(s)
        return /:/.match(s)
      end

      # Check given line to match snippet tag with repo
      def is_tag_line_with_repository(s)
        return is_snip_or_snippet_tag_line(s) && has_colon(s)
      end

      # Get repository name from given line
      def get_repo(s)
        if is_tag_line_with_repository(s)
          # return repository name
          return /<(.*?):/.match(s)[1]
        end

        # return empty string
        return ""
      end

    end
  end
end
