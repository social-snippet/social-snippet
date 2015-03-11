module SocialSnippet::Repository::Models

  class Repository < ::SocialSnippet::Document

    @@core = nil

    field :url, :type => String
    field :name, :type => String
    field :current_ref, :type => String
    field :refs, :type => Array, :default => ::Array.new
    # rev_hash[ref] => Commit ID
    field :rev_hash, :type => Hash, :default => ::Hash.new

    def add_ref(ref, rev_hash)
      add_to_set :refs => ref
      modifier = ::Hash.new
      modifier[ref] = rev_hash
      push :rev_hash => modifier
    end

    # Returns latest version
    def latest_version(pattern = "")
      pattern = "" if pattern.nil?
      matches = versions.select {|ref| ::SocialSnippet::Version.is_matched_version_pattern(pattern, ref)}
      ::VersionSorter.rsort(matches).first
    end

    # Returns all versions
    def versions
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

