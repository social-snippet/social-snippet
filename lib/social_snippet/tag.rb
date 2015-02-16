class SocialSnippet::Tag

  require "pathname"

  attr_reader :path
  attr_reader :repo
  attr_reader :ref
  attr_reader :prefix
  attr_reader :suffix
  attr_reader :spaces

  # Create instance
  #
  # @param s [String] tag line text
  def initialize(s)
    set_path self.class.get_path(s)
    @repo   = self.class.get_repo(s)
    @ref    = self.class.get_ref(s)
    @prefix = self.class.get_prefix(s)
    @suffix = self.class.get_suffix(s)
    @spaces = self.class.get_spaces(s)

    # to normalize repo's path
    set_path self.class.get_path(s)
  end

  # Set information by another tag
  def set_by_tag(base_tag)
    return self if base_tag.nil?
    @prefix = base_tag.prefix
    @suffix = base_tag.suffix
    @spaces = base_tag.spaces
    self
  end

  def filename
    ::Pathname.new(path).basename.to_s
  end

  # Set path
  def set_path(new_path)
    @path = normalize_path(new_path)
  end

  def normalize_path(path)
    # ././foo/bar => foo/bar
    path.gsub! /^\.\//, "" while /^\.\// === path

    # repo:/path/to/file -> repo:path/to/file
    path[0] = "" if has_repo? && path[0] == "/"

    path
  end

  # Set repo
  def set_repo(new_repo)
    @repo = new_repo
  end

  # Set ref
  def set_ref(new_ref)
    @ref = new_ref
  end

  # Check to have ref
  def has_ref?
    return ref.nil? === false && ref != ""
  end

  # Check to have repository
  def has_repo?
    return repo != ""
  end

  # Get path text
  def to_path
    if has_repo?
      if has_ref?
        "#{repo}##{ref}:#{path}"
      else
        "#{repo}:#{path}"
      end
    else
      "#{path}"
    end
  end

  # Get tag text by given tag text
  def to_tag_text(tag_text)
    "#{prefix}#{tag_text}#{spaces}<#{to_path}>#{suffix}"
  end

  # Get @snip tag text
  def to_snip_tag
    return to_tag_text("@snip")
  end

  # Get @snippet tag text
  def to_snippet_tag
    return to_tag_text("@snippet")
  end

  class << self

    def is_no_tag_line?(s)
      /@no_tag/ === s
    end

    def is_cut?(s)
      /@cut/ === s
    end

    def is_begin_cut?(s)
      /@begin_cut/ === s
    end

    def is_end_cut?(s)
      /@end_cut/ === s
    end

    # Check given line to match @snip tag
    def is_snip_tag_line(s)
      return /@snip\s*<.*?>/ === s
    end

    # Check given line to match @snippet tag
    def is_snippet_tag_line(s)
      return /@snippet\s*<.*?>/ === s
    end

    # Check given line to match @snip or @snippet tag
    def is_snip_or_snippet_tag_line(s)
      return is_snip_tag_line(s) || is_snippet_tag_line(s)
    end

    # Check given line to have `#` character
    def has_ref_text(s)
      return /<.*?#(.*?):/ === s
    end

    # Check given line to match `:` character
    def has_colon(s)
      return /:/ === s
    end

    # Check given line to match snippet tag with repo
    def is_tag_line_with_repository(s)
      return is_snip_or_snippet_tag_line(s) && has_colon(s)
    end

    def is_tag_line_with_repository_have_ref(s)
      return is_tag_line_with_repository(s) && has_ref_text(s)
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
        # return suffix text
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
        path = ::Pathname.new(/<(.*?:)?(.*?)>/.match(s)[2])
        return path.cleanpath.to_s
      end

      # return empty string
      return ""
    end

    # Get repo's ref from given line
    def get_ref(s)
      if is_tag_line_with_repository_have_ref(s)
        # return ref text
        return /<.+?#(.*?):/.match(s)[1]
      end

      return ""
    end

    # Get repository name from given line
    def get_repo(s)
      if is_tag_line_with_repository(s)
        # return repository name
        return /<(.*?)[:#]/.match(s)[1]
      end

      # return empty string
      return ""
    end

  end

end
