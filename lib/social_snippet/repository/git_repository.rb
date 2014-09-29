module SocialSnippet
  module Repository
    class GitRepository < BaseRepository

      class << self

        # @return path
        def download(uri)
          raise "not implement download_git_repo"
        end

      end
    end
  end
end
