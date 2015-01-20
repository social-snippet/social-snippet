require "json"

class SocialSnippet::Api

  attr_reader :social_snippet

  # Constructor
  def initialize(new_social_snippet)
    @social_snippet = new_social_snippet
  end

  def config_set(key, value)
    social_snippet.config.set! key, value
  end

  def config_get(key)
    value = social_snippet.config.get(key)
    social_snippet.logger.say "#{key}=#{value}"
  end

  # Initialize snippet.json
  def init_manifest(options = {})
    answer = {}
    json_str = "{}"

    # load current configuration
    if ::File.exists?("snippet.json")
      answer = ::JSON.parse(::File.read "snippet.json")
    end

    questions = [
      {
        :key => "name",
        :type => :string,
        :validate => /[a-zA-Z0-9\.\-_]+/,
        :default => answer["name"],
      },
      {
        :key => "description",
        :type => :string,
        :default => answer["description"],
      },
      {
        :key => "license",
        :default => answer["license"] || "MIT",
        :type => :string,
      },
    ]

    loop do
      answer = ask_manifest_questions(questions, answer)
      json_str = ::JSON.pretty_generate(answer)
      social_snippet.logger.say ""
      social_snippet.logger.say json_str
      social_snippet.logger.say ""
      break if ask_confirm("Is this okay? [Y/N]: ")
    end

    ::File.write "snippet.json", json_str

    answer
  end

  def ask_confirm(message)
    ret = social_snippet.prompt.ask(message) do |q|
      q.limit = 1
      q.validate = /^[yn]$/i
    end
    /y/i === ret
  end

  def ask_manifest_questions(questions, obj)
    questions.inject(obj) do |obj, q|
      q[:default] = obj[q[:key]] = ask_manifest_question(q)
      obj
    end
  end

  def ask_manifest_question(question)
    if question[:type] === :string
      social_snippet.prompt.ask("#{question[:key]}: ") do |q|
        q.default = question[:default]
        if question[:validate].is_a?(Regexp)
          q.validate = question[:validate]
        end
      end
    end
  end

  # Insert snippets to given text
  #
  # @param src [String] The text of source code
  def insert_snippet(src)
    resolver = ::SocialSnippet::Resolvers::InsertResolver.new(social_snippet)
    res = resolver.insert(src)
    output res
    res
  end

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

  def install_repository_by_url(repo_url, repo_ref, options = {})
    output "Cloning repository..."
    repo = ::SocialSnippet::Repository::RepositoryFactory.clone(repo_url)
    install_repository_by_repo repo, repo_ref, options
  end

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

  # Install repository
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

  def update_repository(repo_name, options = {})
    unless social_snippet.repo_manager.exists?(repo_name)
      output "ERROR: #{repo_name} is not installed"
      return
    end

    output "Fetching update for #{repo_name}"
    ret = social_snippet.repo_manager.fetch(repo_name, options)

    repo = social_snippet.repo_manager.find_repository(repo_name)
    display_name = repo_name

    # nothing to update
    if ret == 0 && social_snippet.repo_manager.exists?(repo_name, repo.latest_version)
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
        social_snippet.repo_manager.update repo_name, version, repo, options
      end
      social_snippet.repo_manager.cache_installing_repo repo
    end

    output "Success #{display_name}"

    # update deps
    if social_snippet.repo_manager.has_deps?(repo_name)
      output "Updating #{display_name}'s dependencies"
      deps = social_snippet.repo_manager.deps(repo_name)
      install_missing_dependencies deps, options
      output "Finish updating #{display_name}'s dependencies"
    end
  end

  def update_all_repositories(options = {})
    social_snippet.repo_manager.each_installed_repo do |repo_name|
      update_repository repo_name, options
    end
  end

  def complete_snippet_path(keyword)
    social_snippet.repo_manager.complete(keyword)
  end

  def cli_complete_snippet_path(keyword)
    complete_snippet_path(keyword).each do |cand_repo|
      output cand_repo
    end
  end

  def show_info(repo_name)
    repo_info = social_snippet.registry_client.repositories.find(repo_name)
    output ::JSON.pretty_generate(repo_info)
  end

  def search_repositories(query, options = {})
    format_text = search_result_format(options)
    social_snippet.registry_client.repositories.search(query).each do |repo|
      output format_text % search_result_list(repo, options)
    end
  end

  def add_url(url, options = {})
    ret = social_snippet.registry_client.repositories.add_url(url)
    output ret
  end

  #
  # Helpers
  #

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

  def install_missing_dependencies(repo_deps, options = {})
    repo_deps.each do |dep_repo_name, dep_repo_ref|
      unless social_snippet.repo_manager.exists?(dep_repo_name, dep_repo_ref)
        install_repository_by_name dep_repo_name, dep_repo_ref, options
      end
    end
  end

  def search_result_format(options)
    keys = [ # TODO: improve (change order by option, etc...)
      :name,
      :desc,
      :url,
      :installed,
    ]

    list = []
    keys.each {|key| list.push "%s" if options[key] }

    return list.join(" ")
  end

  def search_result_list(repo, options)
    list = []
    list.push repo["name"] if options[:name]
    list.push "\"#{repo["desc"]}\"" if options[:desc]
    list.push repo["url"] if options[:url]
    list.push search_result_installed(repo) if options[:installed]
    return list
  end

  def search_result_installed(repo)
    if social_snippet.repo_manager.exists?(repo["name"])
      "#installed"
    else
      ""
    end
  end

  def output(message)
    social_snippet.logger.say message
  end

end
