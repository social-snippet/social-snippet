module SocialSnippet::Registry::RegistryResources

  require "rest_client"
  require "json"

  class Base

    attr_reader :core
    attr_reader :rest_client
    attr_reader :end_point
    attr_reader :cookies
    attr_reader :default_headers

    def initialize(new_core)
      @core = new_core
      @end_point      = core.config.sspm_url
      @rest_client    = ::RestClient::Resource.new(end_point)
      @cookies        = {}
      @default_headers = {
        :accept => :json,
      }

      core.logger.debug "registry: end-point = #{end_point}"
    end

    def post(req_path, params, headers = {})
      core.logger.debug "registry: post: #{req_path}"
      core.logger.debug params
      csrf_token = fetch_csrf_token

      # set headers
      headers.merge! default_headers
      headers["Content-Type"] = "application/json"
      headers["X-CSRF-Token"] = csrf_token

      # debug output
      core.logger.debug "registry: post: csrf_token = #{csrf_token}"
      core.logger.debug "registry: post: headers:"
      core.logger.debug headers

      parse_response rest_client[req_path].post(params.to_json, headers)
    end

    def get(req_path, headers = {})
      core.logger.debug "registry: get #{req_path}"
      headers.merge! default_headers
      core.logger.debug "registry: headers:"
      core.logger.debug headers
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
