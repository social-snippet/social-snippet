module SocialSnippet::Registry::RegistryResources

  require "rest_client"
  require "json"

  class Base

    attr_reader :social_snippet
    attr_reader :rest_client
    attr_reader :protocol
    attr_reader :host
    attr_reader :api_version
    attr_reader :end_point
    attr_reader :cookies
    attr_reader :default_headers

    def initialize(new_social_snippet)
      @social_snippet = new_social_snippet
      @host           = social_snippet.config.sspm_host
      @api_version    = social_snippet.config.sspm_version
      @protocol       = social_snippet.config.sspm_protocol
      @end_point      = "#{protocol}://#{host}/api/#{api_version}"
      @rest_client    = ::RestClient::Resource.new(end_point)
      @cookies        = {}
      @default_headers = {
        :accept => :json,
      }

      social_snippet.logger.debug "registry: end-point = #{end_point}"
    end

    def post(req_path, params, headers = {})
      social_snippet.logger.debug "registry: post: #{req_path}"
      social_snippet.logger.debug params
      csrf_token = fetch_csrf_token

      # set headers
      headers.merge! default_headers
      headers["Content-Type"] = "application/json"
      headers["X-CSRF-Token"] = csrf_token

      # debug output
      social_snippet.logger.debug "registry: post: csrf_token = #{csrf_token}"
      social_snippet.logger.debug "registry: post: headers:"
      social_snippet.logger.debug headers

      parse_response rest_client[req_path].post(params.to_json, headers)
    end

    def get(req_path, headers = {})
      social_snippet.logger.debug "registry: get #{req_path}"
      headers.merge! default_headers
      social_snippet.logger.debug "registry: headers:"
      social_snippet.logger.debug headers
      parse_response rest_client[req_path].get(headers)
    end

    private

    def fetch_csrf_token
      unless @csrf_token
        @csrf_token = get("token")
        default_headers.merge! :cookies => cookies
      end
      @csrf_token
    end

    def parse_response(res)
      cookies.merge! res.cookies
      s = res.to_s
      begin
        ::JSON.parse s
      rescue ::JSON::ParserError
        s
      end
    end

  end # Base

end
