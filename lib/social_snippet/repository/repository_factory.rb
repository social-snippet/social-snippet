module SocialSnippet::Repository

  class RepositoryFactory

    attr_reader :core

    def initialize(new_core)
      @core = new_core
    end

    def clone(repo_url)
      uri = ::URI.parse repo_url
      if is_git_repo(uri)
        path = Drivers::GitDriver.download uri
        repo = create_git_repo(path)
        repo.set_url repo_url
        repo.load_snippet_json
        return repo
      else
        raise "unknown repository type"
      end
    end

    def clone_local(repo_path)
      if has_git_dir?(repo_path)
        cloned_path = Drivers::GitDriver.download repo_path
        repo = create_git_repo(cloned_path)
        repo.set_url repo_path
        repo.load_snippet_json
        return repo
      else
        raise "unknown local repository type"
      end
    end

    # Create suitable Repository class instance from path
    #
    # @param path [String] The path of repository
    def create(path, ref = nil, options = {})
      if has_git_dir?(path)
        repo = create_git_repo(path, ref)
        repo.load_snippet_json
        return repo
      end

      return nil
    end

    def create_git_repo(path, ref = nil)
      Drivers::GitDriver.new(core, path, ref)
    end

    def has_git_dir?(dir_path)
      ::Dir.exists?("#{dir_path}/.git")
    end

    def is_git_repo(uri)
      return true if uri.scheme === "git"
      return true if uri.host === "github.com"
      return false
    end

  end # class << self

end # RepositoryFactory
