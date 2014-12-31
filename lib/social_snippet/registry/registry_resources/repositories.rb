module SocialSnippet::Registry::RegistryResources

  class Repositories < Base

    def all
      get "repositories"
    end

    def search(query)
      get "repositories?q=#{query}"
    end

    def find(repo_name)
      get "repositories/#{repo_name}"
    end

    def add_url(repo_url)
      post "repositories", :url => repo_url
    end

  end # Repositories

end # SocialSnippet
