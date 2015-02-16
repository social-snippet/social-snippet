module SocialSnippet

  class Snippet

    attr_reader :filepath
    attr_reader :code
    attr_reader :flag_no_tag

    # Constructor
    def initialize(snippet_path)
      @filepath = snippet_path
      read_file unless filepath.nil?
    end

    def read_file
      @code = ::File.read(filepath).split($/)
    end

    def read_text(s)
      raise "must be passed string" unless s.is_a?(String)
      @code = s.split($/)
    end

    def lines
      @lines ||= new_lines
    end

    def snippet_tags
      TagParser.find_snippet_tags lines
    end

    def snip_tags
      TagParser.find_snip_tags lines
    end

    def no_tag?
      flag_no_tag
    end

    class << self

      # Create instance by text
      def new_text(s)
        raise "must be passed string" unless s.is_a?(String)
        snippet = self.new(nil)
        snippet.read_text s
        snippet
      end

    end

    private

    # Return filtered and styled lines
    def new_lines
      tmp = code.clone
      tmp = filter(tmp)
      tmp
    end

    # @param lines [Array<String>]
    def filter(lines)
      lines = resolve_control_tags(lines)
      lines = filter_range_cut(lines)
      lines = filter_line_cut(lines)
      lines
    end

    def resolve_control_tags(lines)
      @flag_no_tag = (false === TagParser.find_no_tags(lines).empty?)
      lines.reject {|s| Tag.is_control_tag? s }
    end

    def filter_line_cut(lines)
      lines.select {|s| not Tag.is_cut? s }
    end

    def filter_range_cut(lines)
      cut_level = 0
      lines.select do |line|
        if Tag.is_begin_cut?(line)
          cut_level += 1
          false
        elsif Tag.is_end_cut?(line)
          cut_level -= 1
          false
        else
          cut_level === 0
        end
      end
    end

  end

end

