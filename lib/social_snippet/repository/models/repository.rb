module SocialSnippet::Repository::Models

  class Repository < ::SocialSnippet::Document

    @@core = nil

    field :url, :type => String
    field :name, :type => String
    field :current_ref, :type => String
    field :refs, :type => Array, :default => ::Array.new
    # rev_hash[ref] => Commit ID
    field :rev_hash_array, :type => Array, :default => ::Array.new
    # package_refs[ref] => rev_hash
    field :package_refs_array, :type => Array, :default => ::Array.new

    def rev_hash
      @rev_hash_cache ||= rev_hash_array.inject(::Hash.new) do |rev_hash, info|
        rev_hash[info[:ref]] = info[:rev_hash]
        rev_hash
      end
    end

    def package_refs
      @package_refs_cache ||= package_refs_array.inject(::Hash.new) do |package_refs, info|
        package_refs[info[:ref]] = info[:rev_hash]
        package_refs
      end
    end

    def add_package(new_ref)
      add_to_set :package_refs_array => {
        :ref => new_ref,
        :rev_hash => rev_hash[new_ref],
      }
      @package_refs_cache = nil
    end

    def add_ref(new_ref, new_rev_hash)
      add_to_set :refs => new_ref
      add_to_set :rev_hash_array => {
        :ref => new_ref,
        :rev_hash => new_rev_hash,
      }
      @rev_hash_cache = nil
    end

    def has_ref?(ref)
      refs.include? ref
    end

    def package_ref_keys
      package_refs.map {|k, _| k }
    end

    def package_minor_versions
      package_versions.map do |v|
        ::SocialSnippet::Version.minor v
      end.uniq
    end

    def latest_package_version(pattern = "")
      find_latest_version package_versions, pattern
    end

    def package_versions
      select_versions package_ref_keys
    end

    # Returns latest version
    def latest_version(pattern = "")
      find_latest_version versions, pattern
    end

    # Returns all versions
    def versions
      select_versions refs
    end

    def find_latest_version(versions, pattern = "")
      matches = versions.select {|ref| ::SocialSnippet::Version.is_matched_version_pattern(pattern, ref)}
      ::VersionSorter.rsort(matches).first
    end

    def select_versions(refs)
      refs.select {|ref| ::SocialSnippet::Version.is_version(ref) }
    end

    def has_package_versions?
      not package_versions.empty?
    end

    # Check repository has version ref
    def has_versions?
      not versions.empty?
    end

    def core
      @@core
    end

    def self.core
      @@core
    end

    def self.core=(new_core)
      @@core = new_core
    end

  end

end

