module SocialSnippet

  class RegistryClient

    attr_reader :protocol
    attr_reader :host
    attr_reader :api_version

    def initialize(new_host, new_api_version, new_protocol = "http")
      @host = new_host
      @api_version = new_api_version
      @protocol = new_protocol
    end

    def url(path)
      return "#{protocol}://#{host}/api/#{api_version}/#{path}"
    end

    def get_repositories(query = nil)
      params = {}
      params[:q] = query unless query.nil?
      res_body = RestClient.get(
        url("repositories"),
        {
          :accept => :json,
          :params => params,
        },
      )
      return JSON.parse(res_body)
    end

    def get_repository(repo_name)
      res_body = RestClient.get(
        url("repositories/#{repo_name}"),
        {
          :accept => :json,
        },
      )
      return JSON.parse(res_body)
    end

    def get_dependencies(repo_name)
      res_body = RestClient.get(
        url("repositories/#{repo_name}/dependencies"),
        {
          :accept => :json,
        },
      )
      return JSON.parse(res_body)
    end

  end

end
