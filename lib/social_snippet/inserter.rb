module SocialSnippet
  class Inserter
    attr_reader :index
    attr_reader :dest

    # Constructor
    #
    # @param src [Array<String>] The source code
    def initialize(src)
      @index = 0
      @real_index = 0
      if src.empty?
        @offset = -1
      else
        @offset = 0
      end
      @src = src.clone.freeze
      @dest = src.clone
    end

    # Set offset
    #
    # @param new_offset [Number] The next offset
    def set_offset(new_offset)
      @offset = new_offset
      @real_index = @offset + @index
    end

    # Set index
    #
    # @param new_index [Number] The next index
    def set_index(new_index)
      @index = new_index
      @real_index = @offset + @index
    end

    # Insert text
    #
    # @param line_or_lines [String or Array<String>] The inserted text
    def insert(line_or_lines)
      if line_or_lines.is_a?(Array)
        lines = line_or_lines
        if @offset == -1
          @dest.insert @real_index, *lines
        else
          @dest.insert @real_index + 1, *lines
        end
        add_lines lines.length
      else
        line = line_or_lines
        @dest.insert @real_index + 1, line
        add_lines 1
      end
    end

    # Replace current line
    #
    # @param line [String] The replaced text
    def replace(line)
      @dest[@real_index] = line
    end

    # Delete current line
    def remove()
      @dest.delete_at @real_index
      remove_lines 1
    end

    # Get text
    #
    # @return [String]
    def to_s()
      return @dest.join("\n")
    end

    private

    # Add lines
    def add_lines(len)
      if @offset == -1
        set_offset 0
      else
        set_offset @offset + len
      end
    end

    # Remove lines
    def remove_lines(len)
      set_offset @offset - len
    end
  end
end
