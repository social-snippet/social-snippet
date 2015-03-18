module SocialSnippet::Repository::Drivers

  class GitDriver < DriverBase

    attr_reader :rugged_repo

    def fetch
      dest_dir = ::Dir.mktmpdir
      @rugged_repo = ::Rugged::Repository.clone_at(url, dest_dir)
    end

    def snippet_json
      @snippet_json ||= read_snippet_json
    end

    def read_snippet_json
      oid = rugged_repo.head.target.tree["snippet.json"][:oid]
      @snippet_json ||= ::JSON.parse rugged_repo.lookup(oid).read_raw.data
    end

    def read_file(oid)
      rugged_repo.lookup(oid).read_raw.data
    end

    def each_directory(ref, &block)
      rugged_ref(ref).target.tree.walk_trees do |parent, tree|
        yield ::SocialSnippet::Repository::Drivers::Entry.new(join_path(parent, tree[:name]))
      end
    end

    def each_file(ref, &block)
      rugged_ref(ref).target.tree.walk_blobs do |parent, item|
        yield ::SocialSnippet::Repository::Drivers::Entry.new(join_path(parent, item[:name]), read_file(item[:oid]))
      end
    end

    def join_path(a, b)
      if a.empty?
        b
      else
        ::File.join a, b
      end
    end

    def current_ref
      rugged_repo.head.name.gsub /^refs\/heads\//, ""
    end

    def rugged_ref(ref_name)
      rugged_repo.references.each("refs/*/#{ref_name}").first
    end

    def rev_hash(ref)
      rugged_ref(ref).target_id
    end

    def refs
      all_refs = []
      all_refs.concat remote_refs
      all_refs.concat tags
      all_refs
    end

    def remote_refs
      rugged_repo.references.each("refs/remotes/origin/**/*").map do |r|
        r.name.match(/^refs\/remotes\/origin\/(.*)/)[1]
      end
    end

    def tags
      rugged_repo.references.each("refs/tags/**/*").map do |r|
        r.name.match(/^refs\/tags\/(.*)/)[1]
      end
    end

    class << self

      def target_url?(url)
        uri = ::URI.parse(url)
        is_git_uri(uri)
      end

      def is_git_uri(uri)
        /git|https?/ === uri.scheme
      end

      def target_path?(path)
        ::File.directory?(path) && ::File.directory?(::File.join path, ".git")
      end

    end # class << self

  end # GitDriver

  ::SocialSnippet::Repository::DriverFactory.add_driver GitDriver

end # SocialSnippet
