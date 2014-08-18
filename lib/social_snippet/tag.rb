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

    end
  end
end
