module SocialSnippet::Repository

  class RepositoryManager

    attr_reader :installer
    attr_reader :repo_paths
    attr_reader :repo_cache_path
    attr_reader :social_snippet

    # Constructor
    #
    # @param new_social_snippet [::SocialSnippet::Core]
    def initialize(new_social_snippet)
      @social_snippet = new_social_snippet
      @installer = ::SocialSnippet::Repository::RepositoryInstaller.new(social_snippet)
      @repo_cache_path = social_snippet.config.repository_cache_path
      @repo_paths = []

      init_repo_paths
      init_repo_cache_path
    end

    def init_repo_cache_path
      ::FileUtils.mkdir_p repo_cache_path
    end

    def init_repo_paths
      repo_paths.push installer.path
      repo_paths.each {|path| ::FileUtils.mkdir_p path }
    end

    def deps(repo_name, repo_ref = nil)
      repo = find_repository(repo_name)
      repo.checkout(repo_ref) unless repo_ref.nil?
      repo.dependencies
    end

    def has_deps?(repo_name, repo_ref = nil)
      not deps(repo_name, repo_ref).empty?
    end

    # Get snippet by context and tag
    #
    # @param context [::SocialSnippet::Context] The context of snippet
    # @param tag [::SocialSnippet::Tag] The tag of snippet
    def get_snippet(context, tag)
      ::SocialSnippet::Snippet.new(resolve_snippet_path(context, tag))
    end

    # Resolve snippet path by context and tag
    #
    # @param context [::SocialSnippet::Context] The context of snippet
    # @param tag [::SocialSnippet::Tag] The tag of snippet
    def resolve_snippet_path(context, tag)
      if tag.has_repo?
        repo = find_repository_by_tag(tag)
        return repo.real_path tag.path
      end

      new_context = context.clone
      new_context.move tag.path
      "#{new_context.dirname}/#{tag.filename}"
    end

    # Find repository by tag
    #
    # @param tag [::SocialSnippet::Tag] The tag of repository
    def find_repository_by_tag(tag)
      if tag.has_ref?
        find_repository(tag.repo, tag.ref)
      else
        find_repository(tag.repo)
      end
    end

    # Find repository by repo name
    #
    # @param name [String] The name of repository
    def find_repository(name, ref = nil)
      return nil if name.nil? || name.empty?

      repo_paths.each do |repo_path|
        path = "#{repo_path}/#{name}"
        if ::Dir.exists?(path)
          repo = RepositoryFactory.create(path, ref)
          repo.load_cache repo_cache_path
          return repo
        end
      end

      nil
    end

    def find_repositories_start_with(prefix)
      glob_path = ::File.join(installer.path, "#{prefix}*")
      ::Dir.glob(glob_path).map do |repopath|
        Pathname(repopath).basename.to_s
      end
    end

    def complete_repo_name(keyword)
      repo_name = get_repo_name_prefix(keyword)
      find_repositories_start_with(repo_name)
    end

    def complete_file_name(keyword)
      repo_name   = get_repo_name(keyword)
      repo        = find_repository(repo_name)
      file_path   = get_file_path_prefix(keyword)
      glob_path   = "#{file_path}*"

      repo.glob(glob_path).map do |cand_file_path|
        if ::File.directory?(cand_file_path)
          Pathname(cand_file_path).basename.to_s + "/"
        else
          Pathname(cand_file_path).basename.to_s + ">"
        end
      end
    end

    def complete(keyword)
      if is_completing_repo_name?(keyword)
        complete_repo_name(keyword)
      elsif is_completing_file_path?(keyword)
        complete_file_name(keyword)
      else
        raise "completion error"
      end
    end

    def get_repo_name(keyword)
      /^[^@]*@[^<]+<([^:#>]*[^:#>])/.match(keyword)[1]
    end

    def get_repo_name_prefix(keyword)
      /^[^@]*@[^<]+<([^:#>]*[^:#>])$/.match(keyword)[1]
    end

    def get_file_path_prefix(keyword)
      /^[^@]*@[^<]+<[^#:]+:([^>]*)$/.match(keyword)[1]
    end

    def is_completing_repo_name?(keyword)
      /^[^@]*@[^<]+<[^:#>]*$/ === keyword
    end

    def is_completing_file_path?(keyword)
      /^[^@]*@[^<]+<[^#:]+:[^>]*$/ === keyword
    end

    def cache_installing_repo(repo, options = {})
      repo.create_cache repo_cache_path
    end

    def fetch(repo_name, options)
      installer.fetch repo_name, options
    end

    def update(repo_name, repo_ref, repo, options)
      cache_installing_repo repo, options
      installer.add repo_name, repo_ref
    end

    def install(repo_name, repo_ref, repo, options)
      installer.copy_repository repo, options
      update repo_name, repo_ref, repo, options
    end

    def exists?(repo_name, repo_ref = nil)
      installer.exists? repo_name, repo_ref
    end

    def each_installed_repo(&block)
      installer.each &block
    end

  end # RepositoryManager

end # SocialSnippet
