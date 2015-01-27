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

  def output(message)
    social_snippet.logger.say message
  end

end
