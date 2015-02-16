module SocialSnippet::Api::UpdateRepositoryApi

  # Update a repository
  # $ sspm update repo-name
  def update_repository(repo_name, options = {})
    unless core.repo_manager.exists?(repo_name)
      output "ERROR: #{repo_name} is not installed"
      return
    end

    output "Fetching update for #{repo_name}"
    ret = core.repo_manager.fetch(repo_name, options)

    repo = core.repo_manager.find_repository(repo_name)
    display_name = repo_name

    # nothing to update
    if ret == 0 && core.repo_manager.exists?(repo_name, repo.latest_version)
      output "Everything up-to-date"
      return
    end

    output "Updating #{repo_name}"
    unless options[:dry_run]
      version = repo.latest_version
      if repo.has_versions? && repo.current_ref != version
        output "Bumping version into #{version}"
        display_name = "#{repo_name}\##{version}"
        repo.checkout version
        core.repo_manager.update repo_name, version, repo, options
      end
      core.repo_manager.cache_installing_repo repo
    end

    output "Success #{display_name}"

    # update deps
    if core.repo_manager.has_deps?(repo_name)
      output "Updating #{display_name}'s dependencies"
      deps = core.repo_manager.deps(repo_name)
      install_missing_dependencies deps, options
      output "Finish updating #{display_name}'s dependencies"
    end
  end

  # Update all installed repositories
  # $ sspm update
  def update_all_repositories(options = {})
    core.repo_manager.each_installed_repo do |repo_name|
      update_repository repo_name, options
    end
  end

end
