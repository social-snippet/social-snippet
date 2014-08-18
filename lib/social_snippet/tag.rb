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


    end
  end
end
