module SocialSnippet
  module Repository
    class GitRepository < BaseRepository

      attr_reader :repo

      def initialize(repo_path, new_ref = nil)
        @repo = Rugged::Repository.new(repo_path)
        super(repo_path)
      end

      def get_commit_id
        return repo.head.target_id
      end

      def checkout(ref_name)
        repo.checkout(ref_name)
      end

      def get_refs
        refs = []
        refs.concat get_origin_refs
        refs.concat get_tags
        return refs
      end

      def get_origin_refs
        repo.references
          .select {|ref| /^refs\/remotes\/origin\// === ref.name }
          .map {|ref| /^refs\/remotes\/origin\/(.*)/.match(ref.name)[1] }
      end

      def get_tags
        repo.references
          .select {|ref| /^refs\/tags\// === ref.name }
          .map {|ref| /^refs\/tags\/(.*)/.match(ref.name)[1] }
      end

      class << self

        # @return path
        def download(uri, dest_path = nil)
          if dest_path.nil?
            dest_path = Dir.mktmpdir
          end

          # git clone
          cloned_repo = Rugged::Repository.clone_at uri.to_s, dest_path
          cloned_repo_files = cloned_repo.head.target.tree.map {|item| item[:name] }

          # check snippet.json
          unless cloned_repo_files.include?("snippet.json")
            raise "ERROR: Not found snippet.json in the repository"
          end

          dest_path
        end

      end
    end
  end
end
