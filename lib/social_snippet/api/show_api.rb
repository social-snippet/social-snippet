module SocialSnippet::Api::ShowApi

  require "json"

  def show_info(repo_name)
    repo_info = social_snippet.registry_client.repositories.find(repo_name)
    output ::JSON.pretty_generate(repo_info)
  end

end
