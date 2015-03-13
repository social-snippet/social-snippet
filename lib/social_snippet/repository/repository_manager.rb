module SocialSnippet::Repository

  class RepositoryManager

    attr_reader :core

    # Constructor
    #
    # @param new_core [::SocialSnippet::Core]
    def initialize(new_core)
      @core = new_core
    end

    def deps(repo_name, repo_ref = nil)
      find_package(repo_name).dependencies
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
        pkg = find_package_by_tag(tag)
        pkg.snippet_path tag.path
      else
        new_context = context.clone
        new_context.dirname + "/" + tag.filename
      end
    end

    # Find repository by tag
    #
    # @param tag [::SocialSnippet::Tag] The tag of repository
    def find_package_by_tag(tag)
      if tag.has_ref?
        find_package(tag.repo, tag.ref)
      else
        find_package(tag.repo)
      end
    end

    # Find repository by repo name
    #
    # @param name [String] The name of repository
    def find_package(name, ref = nil)
      repo = find_repository(name)
      ref ||= repo.latest_version || repo.current_ref
      raise "invalid references" unless repo.has_ref?(ref)
      Models::Package.find_by(
        :repo_name => name,
        :rev_hash => repo.rev_hash[ref],
      )
    end

    def find_repository(name)
      Models::Repository.find_by(:name => name)
    end

    def find_repositories_start_with(prefix)
      Models::Repository.where(:name => /^#{prefix}.*/).map do |repo|
        repo.name
      end
    end

    def complete_repo_name(keyword)
      repo_name = get_repo_name_prefix(keyword)
      find_repositories_start_with(repo_name)
    end

    def complete_file_name(keyword)
      repo_name = get_repo_name(keyword)
      package   = find_package(repo_name)
      file_path = keyword_filepath(keyword)
      glob_path = "#{file_path}*"

      package.glob(glob_path).map do |cand_file_path|
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

    def keyword_filepath(keyword)
      /^[^@]*@[^<]+<[^#:]+:([^>]*)$/.match(keyword)[1]
    end

    def is_completing_repo_name?(keyword)
      /^[^@]*@[^<]+<[^:#>]*$/ === keyword
    end

    def is_completing_file_path?(keyword)
      /^[^@]*@[^<]+<[^#:]+:[^>]*$/ === keyword
    end

    def install(url, ref, options = ::Hash.new)
      driver = core.repo_factory.clone(url, ref)
      driver.cache(ref)
      driver.package
    end

    def exists?(repo_name, repo_ref = nil)
      # not found repo
      return false unless Models::Repository.where(:name => repo_name).exists?

      repo = Models::Repository.find_by(:name => repo_name)
      if repo_ref.nil?
        true
      else
        Models::Package.where(
          :repo_name => repo_name,
          :rev_hash => repo.rev_hash[repo_ref],
        ).exists?
      end
    end

    def each_repo(&block)
      Models::Repository.all.each &block
    end

  end # RepositoryManager

end # SocialSnippet
