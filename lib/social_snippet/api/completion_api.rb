module SocialSnippet::Api::CompletionApi

  def complete_snippet_path(keyword)
    core.repo_manager.complete(keyword).each do |snippet_path|
      output snippet_path
    end
  end

end
