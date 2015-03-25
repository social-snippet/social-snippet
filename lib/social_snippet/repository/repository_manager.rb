module SocialSnippet::Repository

  class RepositoryManager

    attr_reader :core

    # Constructor
    #
    # @param new_core [::SocialSnippet::Core]
    def initialize(new_core)
      @core = new_core
    end

    # Get snippet by context and tag
    #
    # @param context [::SocialSnippet::Context] The context of snippet
    # @param tag [::SocialSnippet::Tag] The tag of snippet
    def get_snippet(context, tag)
      ::SocialSnippet::Snippet.new(core, resolve_snippet_path(context, tag))
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
      ref ||= repo.latest_package_version || repo.current_ref
      raise "invalid references" unless repo.has_ref?(ref)
      Models::Package.find_by(
        :repo_name => name,
        :rev_hash => repo.rev_hash[ref],
      )
    end

    def find_repository(name)
      Models::Repository.find_by(:name => name)
    end

    def find_repository_by_url(url)
      Models::Repository.find_by(:url => url)
    end

    def find_repositories_start_with(prefix)
      Models::Repository.where(:name => /^#{prefix}.*/).map do |repo|
        repo.name
      end
    end

    def all_repositories
      Models::Repository.all.map {|repo| repo.name }
    end

    def complete_repo_name(keyword)
      repo_name = get_repo_name_prefix(keyword)
      if repo_name.empty?
        all_repositories
      else
        find_repositories_start_with(repo_name)
      end
    end

    def complete_file_name(keyword)
      repo_name = get_repo_name(keyword)
      package   = find_package(repo_name)
      file_path = keyword_filepath(keyword)
      glob_path = "#{package.snippet_json["main"]}/#{file_path}*"

      package.glob(glob_path).map do |cand_file_path|
        if core.storage.directory?(cand_file_path)
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
      /^[^@]*@[^<]+<([^:#>]*)/.match(keyword)[1]
    end

    def get_repo_name_prefix(keyword)
      /^[^@]*@[^<]+<([^:#>]*)$/.match(keyword)[1]
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
      driver = core.driver_factory.clone(url)
      ref ||= resolve_ref_by_driver(driver)
      repo = update_repository(driver, url)
      create_package driver, ref
    end

    def resolve_ref_by_driver(driver)
      driver.latest_version || driver.current_ref
    end

    def update_repository(driver, url)
      repo = Models::Repository.find_or_create_by(:url => url)
      repo.update_attributes! :name => driver.snippet_json["name"]
      driver.each_ref {|ref| repo.add_ref ref, driver.rev_hash(ref) }
      repo
    end

    def create_package(driver, ref)
      repo_name = driver.snippet_json["name"]
      package = Models::Package.create(
        :repo_name => repo_name,
        :rev_hash => driver.rev_hash(ref),
        :name => "#{driver.snippet_json["name"]}##{ref}",
      )

      repo = find_repository(repo_name)
      repo.add_package ref

      driver.each_directory(ref) do |dir|
        package.add_directory dir.path
      end
      driver.each_file(ref) do |content|
        package.add_file content.path, content.data
      end

      unless package.snippet_json["dependencies"].nil?
        package.snippet_json["dependencies"].each do |dep_name, dep_ref|
          package.add_dependency dep_name, dep_ref
        end
      end

      package
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
