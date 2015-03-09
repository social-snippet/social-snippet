module SocialSnippet::Repository::Drivers

  class GitRepository < BaseRepository

    attr_reader :rugged_repo

    def initialize(new_core, repo_path, new_ref = nil)
      @rugged_repo = ::Rugged::Repository.new(repo_path)
      super new_core, repo_path
    end

    def current_ref
      rugged_repo.head.name.gsub /^refs\/heads\//, ""
    end

    def update
      # TODO: write tests
      fetch_status = rugged_repo.fetch("origin")
      fetch_status[:received_bytes]
    end

    def commit_id
      rugged_repo.head.target_id
    end

    def checkout(ref_name)
      rugged_repo.checkout ref_name, :strategy => [:force]
    end

    def refs
      refs = []
      refs.concat remote_refs
      refs.concat tags
      return refs
    end

    def remote_refs
      rugged_repo.references
        .select {|ref| /^refs\/remotes\/origin\// === ref.name }
        .map {|ref| /^refs\/remotes\/origin\/(.*)/.match(ref.name)[1] }
    end

    def tags
      rugged_repo.references
        .select {|ref| /^refs\/tags\// === ref.name }
        .map {|ref| /^refs\/tags\/(.*)/.match(ref.name)[1] }
    end

    class << self

      # @return path
      def download(uri, dest_path = nil)
        if dest_path.nil?
          dest_path = ::Dir.mktmpdir
        end

        # git clone
        cloned_repo = ::Rugged::Repository.clone_at uri.to_s, dest_path
        cloned_repo_files = cloned_repo.head.target.tree.map {|item| item[:name] }

        # check snippet.json
        unless cloned_repo_files.include?("snippet.json")
          raise "ERROR: Not found snippet.json in the repository"
        end

        cloned_repo.close
        dest_path
      end

    end # class << self

  end # GitRepository

end # SocialSnippet
