module SocialSnippet::Api::ShowApi

  def show_info(repo_name)
    repo_info = core.registry_client.repositories.find(repo_name)
    output ::JSON.pretty_generate(repo_info)
  end

end

