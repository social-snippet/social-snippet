module SocialSnippet::Api::CompletionApi

  def complete_snippet_path(keyword)
    core.repo_manager.complete(keyword)
  end

  def cli_complete_snippet_path(keyword)
    complete_snippet_path(keyword).each do |cand_repo|
      output cand_repo
    end
  end

end
