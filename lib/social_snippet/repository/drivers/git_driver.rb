module SocialSnippet::Repository::Drivers

  class GitDriver < DriverBase

    attr_reader :rugged_repo

    def initialize(new_core, new_url, new_ref = nil)
      super new_core, new_url
    end

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

    def each_directory
      rugged_ref(ref).target.tree.each do |c|
        next unless c[:type] == :tree
        yield ::SocialSnippet::Repository::Drivers::Entry.new(c[:name])
      end
    end

    def each_content(&block)
      walk_tree rugged_ref(ref).target.tree, ::Array.new, &block
    end

    def walk_tree(tree, parents)
      tree.each_blob do |c|
        path = ::File.join(*parents, c[:name])
        yield ::SocialSnippet::Repository::Drivers::Entry.new(path, read_file(c[:oid]))
      end
      tree.each_tree do |t|
        parents.push t[:name]
        walk_tree(rugged_repo.lookup(t[:oid]), parents) do |content|
          yield content
        end
        parents.pop
      end
    end

    def each_ref
      refs.each {|r| yield r }
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

    def update
      # TODO: write tests
      fetch_status = rugged_repo.fetch("origin")
      fetch_status[:received_bytes]
    end

    def checkout(ref_name)
      rugged_repo.checkout ref_name, :strategy => [:force]
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

end # SocialSnippet
