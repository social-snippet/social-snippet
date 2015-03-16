module SocialSnippet::Repository::Models

  class Repository < ::SocialSnippet::Document

    @@core = nil

    field :url, :type => String
    field :name, :type => String
    field :current_ref, :type => String
    field :refs, :type => Array, :default => ::Array.new
    # rev_hash[ref] => Commit ID
    field :rev_hash, :type => Hash, :default => ::Hash.new
    # package_refs[ref] => rev_hash
    field :package_refs, :type => Hash, :default => ::Hash.new

    def add_package(ref)
      modifier = ::Hash.new
      modifier[ref] = rev_hash[ref]
      push :package_refs => modifier
    end

    def add_ref(ref, rev_hash)
      add_to_set :refs => ref
      modifier = ::Hash.new
      modifier[ref] = rev_hash
      push :rev_hash => modifier
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

    # Check repository has version ref
    def has_versions?
      versions.empty? === false
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

