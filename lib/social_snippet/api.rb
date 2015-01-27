class SocialSnippet::Api; end
require_relative "api/config_api"
require_relative "api/manifest_api"
require_relative "api/insert_snippet_api"
require_relative "api/install_repository_api"
require_relative "api/update_repository_api"
require_relative "api/completion_api"
require_relative "api/show_api"
require_relative "api/search_api"
require_relative "api/registry_api"
require "json"

class SocialSnippet::Api

  attr_reader :social_snippet

  # Constructor
  def initialize(new_social_snippet)
    @social_snippet = new_social_snippet
  end

  include ::SocialSnippet::Api::ConfigApi
  include ::SocialSnippet::Api::ManifestApi
  include ::SocialSnippet::Api::InsertSnippetApi
  include ::SocialSnippet::Api::InstallRepositoryApi
  include ::SocialSnippet::Api::UpdateRepositoryApi
  include ::SocialSnippet::Api::CompletionApi
  include ::SocialSnippet::Api::ShowApi
  include ::SocialSnippet::Api::SearchApi
  include ::SocialSnippet::Api::RegistryApi

  #
  # Helpers
  #

  private

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

  def ask_confirm(message)
    ret = social_snippet.prompt.ask(message) do |q|
      q.limit = 1
      q.validate = /^[yn]$/i
    end
    /y/i === ret
  end

  def ask_manifest_questions(questions, obj)
    questions.inject(obj) do |obj, q|
      obj[q[:key]] = ask_manifest_question(q)
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

  def manifest_questions(answer)
    [
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
  end

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
