module SocialSnippet::Api::InstallRepositoryApi

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

end
