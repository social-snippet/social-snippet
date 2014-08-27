require_relative "social_snippet/version"
require_relative "social_snippet/tag"
require_relative "social_snippet/tag_parser"
require_relative "social_snippet/config"
require_relative "social_snippet/repository"
require_relative "social_snippet/context"

module SocialSnippet
  class SocialSnippet
    # Constructor
    def initialize()
      @config = Config.new()
      init_repo()
    end

    # Initialize for repository
    def init_repo()
      # repositories
      @repo_paths = []
      @repo_paths.push "#{@config.home}/repo"
      @repo_paths.each {|path| FileUtils.mkdir_p path }

      # repository cache
      @repo_cache_path = "#{@config.home}/repo_cache"
      FileUtils.mkdir_p @repo_cache_path
    end

    # Resolve snippet path from tag
    def resolve_snippet_path(context, tag)
      if tag.has_repo?()
        context.move tag.path, tag.repo
        repo = find_repository(tag.repo)
        if repo.is_cached?()
          return "#{repo.cache_path}/#{repo.main}/#{tag.path}"
        else
          return "#{repo.path}/#{repo.main}/#{tag.path}"
        end
      end

      context.move tag.path
      return context.path
    end

    # Find repository by repo name
    def find_repository(name, ref = nil)
      @repo_paths.each do |repo_path|
        path = "#{repo_path}/#{name}"
        if Dir.exists?(path)
          return create_repository_instance(path, ref)
        end
      end

      return nil
    end

    # Create suitable Repository class instance
    def create_repository_instance(path, ref = nil)
      if is_git_dir(path)
        repo = Repository::GitRepository.new(path)
        repo.checkout(ref)
        repo.load_snippet_json()
        repo.create_cache(@repo_cache_path)
        return repo
      end

      return nil
    end

    # Alias for SocialSnippet.is_git_dir()
    def is_git_dir(path)
      return SocialSnippet.is_git_dir(path)
    end

    class << self
      # Check given path is git repository
      def is_git_dir(path)
        return Dir.exists?("#{path}/.git")
      end
    end
  end
end

