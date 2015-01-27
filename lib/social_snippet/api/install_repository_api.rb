module SocialSnippet::Api::InstallRepositoryApi

  # Install repository (Core API)
  #
  # @param repo [::SocialSnippet::Repository::Drivers::BaseRepository]
  def install_repository(repo_name, repo_ref, repo, options = {})
    display_name = repo_name

    if repo_ref.nil?
      repo_ref = resolve_reference(repo)

      if repo.has_versions?
        output "Resolving #{display_name}'s version"
      else
        output "No versions, use current reference"
      end
    end

    display_name = "#{repo_name}\##{repo_ref}"

    output "Installing: #{display_name}"
    unless options[:dry_run]
      social_snippet.repo_manager.install repo_name, repo_ref, repo, options
    end

    output "Success: #{display_name}"

    # install dependencies
    if has_dependencies?(repo)
      output "Finding #{display_name}'s dependencies"
      install_missing_dependencies repo.dependencies, options
      output "Finish finding #{display_name}'s dependencies"
    end
  end

  # $ sspm install name
  def install_repository_by_name(repo_name, repo_ref, options = {})
    installed_as = repo_name
    installed_as = options[:name] unless options[:name].nil?

    unless installed_as === repo_name
      output "Installing as #{installed_as}"
    end

    if social_snippet.repo_manager.exists?(installed_as, repo_ref)
      output "#{installed_as} is already installed"
      return
    end

    output "Finding: #{repo_name}"
    info = social_snippet.registry_client.repositories.find(repo_name)
    output "Found at: #{info["url"]}"

    output "Cloning repository..."
    repo = ::SocialSnippet::Repository::RepositoryFactory.clone(info["url"])

    install_repository installed_as, repo_ref, repo
  end

  # $ sspm install URL
  def install_repository_by_url(repo_url, repo_ref, options = {})
    output "Cloning repository..."
    repo = ::SocialSnippet::Repository::RepositoryFactory.clone(repo_url)
    install_repository_by_repo repo, repo_ref, options
  end

  # $ sspm install ./path/to/repo
  def install_repository_by_path(repo_path, repo_ref, options = {})
    output "Cloning repository..."
    repo = ::SocialSnippet::Repository::RepositoryFactory.clone_local(repo_path)
    install_repository_by_repo repo, repo_ref, options
  end

  def install_repository_by_repo(repo, repo_ref, options)
    installed_as = repo.name
    installed_as = options[:name] unless options[:name].nil?
    output "Installing as #{installed_as}"

    if social_snippet.repo_manager.exists?(installed_as)
      output "#{installed_as} is already installed"
      return
    end

    install_repository installed_as, repo_ref, repo
  end

  def install_missing_dependencies(repo_deps, options = {})
    repo_deps.each do |dep_repo_name, dep_repo_ref|
      unless social_snippet.repo_manager.exists?(dep_repo_name, dep_repo_ref)
        install_repository_by_name dep_repo_name, dep_repo_ref, options
      end
    end
  end

  private

  def resolve_reference(repo)
    if repo.has_versions?
      repo.latest_version
    else
      repo.current_ref
    end
  end

  def has_dependencies?(repo)
    repo.dependencies && ( not repo.dependencies.empty? )
  end

end
