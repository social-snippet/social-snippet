module SocialSnippet
  class Inserter
    attr_reader :src_index
    attr_reader :dest_index
    attr_reader :src
    attr_reader :dest

    # Constructor
    #
    # @param src [Array<String>] The source code
    def initialize(src)
      @src_index = 0
      @dest_index = -1
      @src = src.clone.freeze
      @dest = []
    end

    # Set index
    #
    # @param new_index [Number] The next index
    def set_index(new_index)
      if new_index > src.length
        raise "invalid index"
      end
      if new_index > src_index
        last_index = [new_index - 1, src.length - 1].min
        insert src[src_index .. last_index]
        @src_index = new_index
      end
    end

    # Set index to last
    def set_index_last
      set_index src.length
    end

    # Ignore current line
    def ignore
      @src_index += 1
    end

    # Insert text
    #
    # @param line_or_lines [String or Array<String>] The inserted text
    def insert(line_or_lines)
      if line_or_lines.is_a?(Array)
        lines = line_or_lines
        @dest.insert dest_index + 1, *lines
        @dest_index += lines.length
      else
        line = line_or_lines
        @dest.insert dest_index + 1, line
        @dest_index += 1
      end
    end

    # Get text
    #
    # @return [String]
    def to_s
      return dest.join("\n")
    end
  end
end
