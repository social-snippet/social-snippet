class SocialSnippet::Context

  attr_reader :flag_absolute
  attr_reader :path
  attr_reader :repo
  attr_reader :ref

  # Constructor
  #
  # @param new_path [String] The path of context
  def initialize(new_path, new_repo = nil, new_ref = nil)
    @flag_absolute = is_absolute_path(new_path)
    @path = new_path
    @repo = new_repo
    @ref  = new_ref
  end

  # Check context in repo
  #
  # @return [Boolean]
  def is_in_repository?
    repo.nil? === false
  end

  # Move to new path from current path
  #
  # @param new_path [String] The next path
  # @param new_repo [String] The next repository
  # @param new_ref [String] The next reference
  def move(new_path, new_repo = nil, new_ref = nil)
    if new_repo.nil?
      if is_absolute_path(new_path)
        @flag_absolute = true
        @path = new_path
      else
        @path = move_func(new_path)
      end
    else
      @flag_absolute = false
      @path = new_path
      @repo = new_repo
      @ref  = new_ref
    end
  end

  private

  def move_func(new_path)
    source = path.split("/")
    source_file = source.pop
    dest = new_path.split("/")
    dest_file = dest.pop

    if is_absolute_path(path)
      source.shift
    end

    dest.each do |x|
      if is_dotdot(x)
        source.pop
      elsif ! is_dot(x)
        source.push x
      end
    end

    if flag_absolute
      "/" + source.join("/") + "/" + dest_file
    else
      source.join("/") + "/" + dest_file
    end
  end

  private
  # Check given text is absolute path
  def is_absolute_path(s)
    s[0] === "/"
  end

  # Check given text is `.`
  def is_dot(s)
    s === "."
  end

  # Check given text is `..`
  def is_dotdot(s)
    s === ".."
  end

end
