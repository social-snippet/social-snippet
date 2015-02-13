class SocialSnippet::Snippet

  attr_reader :filepath
  attr_reader :code

  # Constructor
  def initialize(snippet_path)
    @filepath = snippet_path
    read_file unless filepath.nil?
  end

  def read_file
    @code = ::File.read(filepath)
  end

  def read_text(s)
    @code = s
  end

  def lines
    @lines ||= new_lines
  end

  def snippet_tags
    ::SocialSnippet::TagParser.find_snippet_tags lines
  end

  def snip_tags
    ::SocialSnippet::TagParser.find_snip_tags lines
  end

  class << self

    # Create instance by text
    def new_text(s)
      snippet = self.new(nil)
      snippet.read_text s
      snippet
    end

  end

  private

  # Return filtered and styled lines
  def new_lines
    lines = code.split $/
    lines = filter(lines)
    lines
  end

  # @param lines [Array<String>]
  def filter(lines)
    lines = cut_filter(lines)
    lines
  end

  def cut_filter(lines)
    cut_level = 0
    lines.select do |line|
      if ::SocialSnippet::Tag.is_begin_cut?(line)
        cut_level += 1
        false
      elsif ::SocialSnippet::Tag.is_end_cut?(line)
        cut_level -= 1
        false
      else
        cut_level === 0
      end
    end
  end

end
