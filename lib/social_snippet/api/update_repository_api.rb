module SocialSnippet::Api::UpdateRepositoryApi

  # Update a repository
  # $ sspm update repo-name
  def update_repository(name, options = {})
    unless core.repo_manager.exists?(name)
      raise "ERROR: #{name} is not installed"
    end

    output "Fetching update for #{name}"
    repo = core.repo_manager.find_repository(name)
    driver = core.driver_factory.clone(repo.url)
    # reload repository
    repo = core.repo_manager.update_repository(driver, repo.url)

    unless update_repository_for_each_minor_version(driver, repo, options)
      output "Everything up-to-date"
    end
  end

  # Update all installed repositories
  # $ sspm update
  def update_all_repositories(options = {})
    core.repo_manager.each_repo do |repo|
      update_repository repo.name, options
    end
  end

  def update_repository_for_each_minor_version(driver, repo, options)
    repo.package_minor_versions.any? do |minor_version|
      latest_version = driver.latest_version(minor_version)
      next false if core.repo_manager.exists?(repo.name, latest_version)

      output "Updating #{repo.name}##{minor_version}.x"
      package = create_new_version_package(driver, latest_version)
      output "Success #{package.display_name}"

      if package.has_dependencies?
        output "Updating #{package.display_name}'s dependencies"
        install_missing_dependencies package.dependencies, options
        output "Finish updating #{package.display_name}'s dependencies"
      end

      true
    end
  end

  def create_new_version_package(driver, new_version)
    output "Bumping version into #{new_version}"
    core.repo_manager.create_package driver, new_version
  end

end
