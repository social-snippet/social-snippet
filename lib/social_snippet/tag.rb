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

    # Check to have repository
    def has_repo()
      return @repo != ""
    end

    # Get tag text by given tag
    def to_tag_text(tag)
      if has_repo()
        return "#{@prefix}#{tag}#{@spaces}<#{@repo}:#{@path}>#{@suffix}"
      end
      "#{@prefix}#{tag}#{@spaces}<#{@path}>#{@suffix}"
    end

    # Get @snip tag text
    def to_snip_tag()
      return to_tag_text("@snip")
    end

    # Get @snip tag text
    def to_snippet_tag()
      return to_tag_text("@snippet")
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

      # Get spaces from given line
      def get_spaces(s)
        if is_snip_or_snippet_tag_line(s)
          # return spaces
          return /(@snip|@snippet)(\s*?)</.match(s)[2]
        end

        # return empty string
        return ""
      end

      # Get suffix from given line
      def get_suffix(s)
        if is_snip_or_snippet_tag_line(s)
          # return prefix text
          return />(.*)/.match(s)[1]
        end

        # return empty string
        return ""
      end

      # Get prefix from given line
      def get_prefix(s)
        if is_snip_or_snippet_tag_line(s)
          # return prefix text
          return /(.*?)@/.match(s)[1]
        end

        # return empty string
        return ""
      end

      # Get path from given line
      def get_path(s)
        if is_snip_or_snippet_tag_line(s)
          # return snippet path (without repo name)
          return /<(.*?:)?(.*?)>/.match(s)[2]
        end

        # return empty string
        return ""
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
