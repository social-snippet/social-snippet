module SocialSnippet::Repository

  # Repository base class
  # usage: class GitDriver < DriverBase
  class Drivers::DriverBase

    attr_reader :core
    attr_reader :url
    attr_reader :ref
    attr_reader :repo

    # @example
    # driver = Driver.new(core, url, ref)
    # driver.fetch
    # driver.cache # => save data into storage
    def initialize(new_core, new_url, new_ref = nil)
      @core = new_core
      @url  = new_url
      @ref  = new_ref
      @repo = nil
    end

    def cache
      resolve_ref
      create_package
      update_repository
    end

    def resolve_ref
      @ref ||= latest_version || current_ref
    end

    def update_repository
      @repo = Models::Repository.find_or_create_by(
        :url => url,
      )
      repo.update_attributes! :name => snippet_json["name"]
      each_ref {|ref| repo.add_ref ref, rev_hash(ref) }
    end

    def create_package
      pkg = Models::Package.new(
        :repo_name => snippet_json["name"],
        :rev_hash => rev_hash(ref),
      )
      each_directory do |dir|
        pkg.add_directory dir.path
      end
      each_content do |content|
        pkg.add_file content.path, content.data
      end
    end

    # Returns latest version
    #
    # @param pattern [String] The pattern of version
    # @return [String] The version
    def latest_version(pattern = "")
      pattern = "" if pattern.nil?
      matched_versions = versions.select {|ref| ::SocialSnippet::Version.is_matched_version_pattern(pattern, ref)}
      ::VersionSorter.rsort(matched_versions).first
    end

    # Returns all versions
    #
    # @return [Array<String>] All versions of repository
    def versions
      refs.select {|ref| ::SocialSnippet::Version.is_version(ref) }
    end

    def has_versions?
      not versions.empty?
    end

    def refs
      raise "not implemented"
    end

    def snippet_json
      raise "not implemented"
    end

    def rev_hash(ref)
      raise "not implemented"
    end

    def current_ref
      raise "not implemented"
    end

    def fetch
      raise "not implemented"
    end

    def each_ref
      raise "not implemented"
    end

    def each_directory
      raise "not implemented"
    end

    def each_content
      raise "not implemented"
    end

    class << self

      def target?(url)
        if is_local_path?(url)
          target_local_path?(url)
        elsif is_url?(url)
          target_url?(url)
        end
      end

      def target_url?(url)
        raise "not implemented"
      end

      def target_path?(path)
        raise "not implemented"
      end

      def is_local_path?(s)
        not /^[^:]*:\/\// === s
      end

      def is_url?(s)
        ::URI.regexp === s
      end

    end

  end # DriverBase

end # SocialSnippet
