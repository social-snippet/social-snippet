module SocialSnippet::Repository::Drivers

  # Repository base class
  # usage: class GitRepository < DriverBase
  class DriverBase

    attr_reader :core
    attr_reader :path
    attr_reader :cache_path
    attr_reader :name
    attr_reader :desc
    attr_reader :main
    attr_reader :ref
    attr_reader :dependencies
    attr_reader :ref
    attr_reader :url

    # Constructor
    #
    # @param path [String] The path of repository
    def initialize(new_core, new_path, new_ref = nil)
      @core = new_core
      @path = new_path
      @cache_path = nil
      @ref = new_ref

      if ( not ref.nil? ) && ( not refs.empty? ) && ( not refs.include?(ref) )
        raise Errors::NotExistRef
      end

      @url = nil
    end

    # Set repo's URL
    def set_url(new_url)
      @url = new_url
    end

    def load_cache(base_cache_path)
      cache_path_cand = "#{base_cache_path}/#{name}/#{short_commit_id}"

      if ::Dir.exists?(cache_path_cand)
        return @cache_path = cache_path_cand
      end

      return @cache_path = nil
    end

    # Create cache of repository
    #
    # @param cache_path [String] The path of cache dir
    # @return [String] the path
    def create_cache(base_cache_path)
      @cache_path = "#{base_cache_path}/#{name}/#{short_commit_id}"

      return if ::Dir.exists?(cache_path)

      core.storage.mkdir_p "#{base_cache_path}/#{name}"
      core.storage.cp_r path, cache_path

      return cache_path
    end

    # Load snippet.json file
    def load_snippet_json
      text = ::File.read(::File.join(path, "snippet.json"))
      snippet_json = ::JSON.parse(text)
      @name = snippet_json["name"]
      @desc = snippet_json["desc"]
      @main = snippet_json["main"] || ""
      @dependencies = snippet_json["dependencies"] || {}
    end

    # Returns json text from repo instance
    # 
    # @return json text
    def to_snippet_json
      required = [
        :name,
      ]

      optional = [
        :desc,
        :main,
        :dependencies,
      ]

      data = {}
      required.each do |key|
        data[key] = send(key)
      end
      optional.each do |key|
        val = send(key)
        if val.nil? === false && val != ""
          data[key] = send(key)
        end
      end

      return data.to_json
    end

    # Returns latest version
    #
    # @param pattern [String] The pattern of version
    # @return [String] The version
    def latest_version(pattern = "")
      pattern = "" if pattern.nil?
      matched_versions = versions.select {|ref| ::SocialSnippet::Version.is_matched_version_pattern(pattern, ref)}
      return ::VersionSorter.rsort(matched_versions).first
    end

    # Returns all versions
    #
    # @return [Array<String>] All versions of repository
    def versions
      refs.select {|ref| ::SocialSnippet::Version.is_version(ref) }
    end

    def current_ref
      raise "not implete current_ref"
    end

    # Returns all refs
    #
    # @return [Array<String>] All references of repository
    def refs
      raise "not implement refs"
    end

    # Returns short current ref's commit id
    #
    # @return [String]
    def short_commit_id
      commit_id[0..7]
    end

    # Returns current ref's commit id
    #
    # @return [String]
    def commit_id
      raise "not implement commit_id"
    end

    # Returns the directory or file names within repository
    #
    # @param glob_path [String]
    def glob(glob_path)
      root_path = real_path("/")
      ::Dir.glob("#{root_path}/#{glob_path}")
    end

    # Returns the real path of given path
    #
    # @param target_path [String] The real path of repo's file or directory
    def real_path(target_path)
      # TODO: normalize path
      if is_cached?
        "#{cache_path}/#{main}/#{target_path}"
      else
        "#{path}/#{main}/#{target_path}"
      end
    end

    # Checkout to ref
    #
    # @param ref [String] The reference of repository
    def checkout(new_ref)
      raise "not implement checkout"
    end

    # Check repository has version ref
    #
    # @return [Boolean]
    def has_versions?
      versions.empty? === false
    end

    # Check repository is cached
    #
    # @return [Boolean]
    def is_cached?
      @cache_path.nil? === false
    end

    def update(options = {})
      throw "not implement update"
    end

  end # DriverBase

end # SocialSnippet
