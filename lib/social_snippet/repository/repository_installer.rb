module SocialSnippet::Repository

  class RepositoryInstaller

    attr_reader :core
    attr_reader :data

    def initialize(new_core)
      @core = new_core
      init_data
    end

    def path
      core.config.install_path
    end

    def data_file
      core.config.installed_repos_file
    end

    def init_data
      ::FileUtils.touch data_file
      load
      reset unless data
    end

    def reset
      @data = {}
      save
    end

    def load
      @data = ::YAML.load_file(data_file)
    end

    def save
      ::File.write data_file, data.to_yaml
    end

    def add(repo_name, repo_ref)
      data[repo_name] ||= Set.new
      data[repo_name].add repo_ref
      save
    end

    def remove(repo_name, repo_ref)
      data[repo_name] ||= Set.new
      data[repo_name].delete repo_ref
      save
    end

    def exists?(repo_name, repo_ref = nil)
      data[repo_name] ||= Set.new
      if repo_ref.nil?
        data[repo_name].empty? === false
      else
        data[repo_name].include? repo_ref
      end
    end

    def copy_repository(repo, options = {})
      core.logger.debug "repository_installer: repo.path = #{repo.path}"
      ::FileUtils.cp_r repo.path, repo_path(repo.name)
    end

    def fetch(repo_name, options)
      repo = ::SocialSnippet::Repository::RepositoryFactory.create(repo_path(repo_name), options)
      repo.update
    end

    def repo_path(name)
      ::File.join(path, name)
    end

    def each(&block)
      data
        .select {|repo_name, repo_refs| not repo_refs.empty? }
        .keys
        .each {|repo_name| block.call repo_name }
    end

  end # RepositoryInstaller

end # SocialSnippet

