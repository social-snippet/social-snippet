module SocialSnippet
  class Snippet
    attr_reader :path
    attr_reader :code
    attr_reader :lines

    # Constructor
    def initialize(snippet_path)
      @path = snippet_path
      @code = File.read(@path)
      @lines = @code.split("\n")
    end

  end
end

