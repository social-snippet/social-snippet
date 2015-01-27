module SocialSnippet::Api::SearchApi

  # $ sspm search query
  def search_repositories(query, options = {})
    format_text = search_result_format(options)
    social_snippet.registry_client.repositories.search(query).each do |repo|
      output format_text % search_result_list(repo, options)
    end
  end

end
