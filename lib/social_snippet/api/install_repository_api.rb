module SocialSnippet::Api::InstallRepositoryApi

  def resolve_name_by_registry(repo_name)
    output "Finding #{repo_name}..."
    info = core.registry_client.repositories.find(repo_name)
    output "Found at #{info["url"]}"
    info["url"]
  end

  # Install repository
  #
  # @param url [String]
  # @param ref [String]
  def install_repository(url, ref, options = {})
    output "Installing #{url}..."

    unless options[:dry_run]
      package = core.repo_manager.install(url, ref, options)
    end
    output "Success #{url}"

    if package && package.has_dependencies?
      output "Finding package dependencies..."
      install_missing_dependencies package.dependencies, options
      output "Finished finding package dependencies."
    end
  end

  def install_missing_dependencies(repo_deps, options = {})
    repo_deps.each do |dep_repo_name, dep_repo_ref|
      unless core.repo_manager.exists?(dep_repo_name, dep_repo_ref)
        url = resolve_name_by_registry(dep_repo_name)
        install_repository url, dep_repo_ref, options
      end
    end
  end

  private

  def resolve_reference_by_repo(repo)
    if repo.has_versions?
      output "Resolving #{display_name}'s version"
      repo.latest_version
    else
      output "No versions, use current reference"
      repo.current_ref
    end
  end

end
