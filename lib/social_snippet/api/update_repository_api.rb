module SocialSnippet::Api::UpdateRepositoryApi

  # Update a repository
  # $ sspm update repo-name
  def update_repository(name, options = {})
    display_name = name

    unless core.repo_manager.exists?(name)
      raise "ERROR: #{display_name} is not installed"
    end

    output "Fetching update for #{display_name}"
    repo = core.repo_manager.find_repository(name)
    driver = core.repo_factory.clone(repo.url)

    # nothing to update
    if core.repo_manager.exists?(name, repo.latest_version)
      output "Everything up-to-date"
      return
    end

    output "Updating #{display_name}"
    unless options[:dry_run]
      if repo.has_versions?
        version = repo.latest_version
        output "Bumping version into #{version}"
        display_name = "#{name}##{version}"
        driver.cache version
      end
    end

    output "Success #{display_name}"

    # update deps
    if driver.package.has_dependencies?
      output "Updating #{display_name}'s dependencies"
      install_missing_dependencies driver.package.dependencies, options
      output "Finish updating #{display_name}'s dependencies"
    end
  end

  # Update all installed repositories
  # $ sspm update
  def update_all_repositories(options = {})
    core.repo_manager.each_repo do |repo|
      update_repository repo.name, options
    end
  end

end
