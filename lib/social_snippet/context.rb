module SocialSnippet
  class Context
    attr_reader :path
    attr_reader :repo

    # Constructor
    def initialize(new_path, new_repo = nil)
      @flag_absolute = false
      @path = new_path
      @repo = new_repo
    end

    # Move to new path from current path
    def move(new_path, new_repo = nil)
      if new_repo.nil?
        # without repo
        if is_absolute_path(new_path)
          @flag_absolute = true
          @path = new_path
        else
          @path = move_to_new_path(new_path)
        end
      else
        # with repo
        @flag_absolute = false
        @path = new_path
        @repo = new_repo
      end
    end

    # Move to new path from current path actually
    def move_to_new_path(new_path)
      source = @path.split("/")
      source_file = source.pop()
      dest = new_path.split("/")
      dest_file = dest.pop()

      dest.each do |x|
        if is_dotdot(x)
          source.pop()
        elsif ! is_dot(x)
          source.push x
        end
      end

      if @flag_absolute
        return "/" + source.join("/") + "/" + dest_file
      else
        return source.join("/") + "/" + dest_file
      end
    end

    private
    # Check given text is absolute path
    def is_absolute_path(s)
      return s[0] === "/"
    end

    # Check given text is `.`
    def is_dot(s)
      return s == "."
    end

    # Check given text is `..`
    def is_dotdot(s)
      return s == ".."
    end

  end
end
