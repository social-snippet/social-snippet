require_relative "repository/base_repository"
require_relative "repository/git_repository"
require_relative "repository/repository_errors"

module SocialSnippet

  module Repository

    class << self

      def clone(repo_url)
        uri = URI.parse repo_url
        if is_git_repo(uri)
          path = GitRepository.download uri
          repo = create_git_repo(path)
          repo.set_url repo_url
          return repo
        else
          raise "unknown repository type"
        end
      end

      def create_git_repo(repo_path)
        return GitRepository.new(repo_path)
      end

      def is_git_repo(uri)
        return true if uri.scheme === "git"
        return true if uri.host === "github.com"
        return false
      end

    end

  end

end
