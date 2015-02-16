module SocialSnippet::Api::SearchApi

  # $ sspm search query
  def search_repositories(query, options = {})
    format_text = search_result_format(options)
    core.registry_client.repositories.search(query).each do |repo|
      output format_text % search_result_list(repo, options)
    end
  end

  private

  def search_result_list(repo, options)
    list = []
    list.push repo["name"] if options[:name]
    list.push "\"#{repo["desc"]}\"" if options[:desc]
    list.push repo["url"] if options[:url]
    list.push search_result_installed(repo) if options[:installed]
    return list
  end

  def search_result_installed(repo)
    if core.repo_manager.exists?(repo["name"])
      "#installed"
    else
      ""
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

end
