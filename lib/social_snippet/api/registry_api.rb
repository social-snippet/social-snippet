module SocialSnippet::Api::RegistryApi

  def add_url(url, options = {})
    ret = social_snippet.registry_client.repositories.add_url(url)
    output ret
  end

end
