module SocialSnippet
  class RepositoryManager

    attr_reader :install_path
    attr_reader :repo_paths
    attr_reader :repo_cache_path

    # Constructor
    #
    # @param config [SocialSnippet::Config] The config of manager
    def initialize(config)
      @install_path = "#{config.home}/repo"

      # path
      @repo_paths = []
      @repo_paths.push install_path
      @repo_paths.each {|path| FileUtils.mkdir_p path }

      # cache path
      @repo_cache_path = "#{config.home}/repo_cache"
      FileUtils.mkdir_p @repo_cache_path
    end

    # Create suitable Repository class instance
    #
    # @param path [String] The path of repository
    def create_repository_instance(path, ref = nil)
      if is_git_dir(path)
        repo = Repository::GitRepository.new(path, ref)
        if ref.nil? && repo.has_versions?
          repo.checkout repo.get_latest_version
        end
        repo.load_snippet_json
        repo.create_cache(@repo_cache_path)
        return repo
      end

      return nil
    end

    # Get snippet
    #
    # @param context [SocialSnippet::Context] The context of snippet
    # @param tag [SocialSnippet::Tag] The tag of snippet
    def get_snippet(context, tag)
      return Snippet.new(resolve_snippet_path(context, tag))
    end

    # Resolve snippet path from tag
    #
    # @param context [SocialSnippet::Context] The context of snippet
    # @param tag [SocialSnippet::Tag] The tag of snippet
    def resolve_snippet_path(context, tag)
      if tag.has_repo?
        repo = find_repository_by_tag(tag)
        return repo.get_real_path tag.path
      end

      new_context = context.clone
      new_context.move tag.path
      return new_context.path
    end

    # Find repository by tag
    #
    # @param tag [SocialSnippet::Tag] The tag of repository
    def find_repository_by_tag(tag)
      if tag.has_ref?
        return find_repository(tag.repo, tag.ref)
      else
        return find_repository(tag.repo)
      end
    end

    # Find repository by repo name
    #
    # @param name [String] The name of repository
    def find_repository(name, ref = nil)
      repo_paths.each do |repo_path|
        path = "#{repo_path}/#{name}"
        if Dir.exists?(path)
          return create_repository_instance(path, ref)
        end
      end

      return nil
    end

    def install_repository(repo)
      FileUtils.cp_r repo.path, "#{install_path}/#{repo.name}"
    end

    private

    # Alias for SocialSnippet.is_git_dir
    def is_git_dir(path)
      return RepositoryManager.is_git_dir(path)
    end

    class << self
      # Check given path is git repository
      def is_git_dir(path)
        return Dir.exists?("#{path}/.git")
      end
    end
  end
end
