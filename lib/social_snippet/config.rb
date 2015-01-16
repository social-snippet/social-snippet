class SocialSnippet::Config

  require "json"

  attr_reader :social_snippet
  attr_reader :home
  attr_reader :fields

  # prefix of environment variables
  ENV_PREFIX = "SOCIAL_SNIPPET_"

  ENV_FIELDS = [
    # Enable debug mode? [default: false]
    :debug,
    # Web API host [default: "sspm.herokuapp.com"]
    :sspm_host,
    # Web API version [default: "v0"]
    :sspm_version,
    # Web API protocol [default: "https"]
    :sspm_protocol,
  ]

  # use "true" / "false"
  ENV_FLAGS = [
    :debug,
  ]

  # Constructor
  def initialize(new_social_snippet, options = {})
    @social_snippet = new_social_snippet
    @fields = {}
    resolve_home

    # env vars > args > config.json
    init_directories
    load_file
    load_options options
    load_environment_variables

    # set default values
    set_default :sspm_host, "sspm.herokuapp.com"
    set_default :sspm_version, "v0"
    set_default :sspm_protocol, "https"

    ENV_FIELDS.each do |field_name|
      key = "@#{field_name.to_s}".to_sym
      instance_variable_set key, fields[field_name]
    end

    save_file
  end

  def set_default(key, value)
    key = normalize_key(key)
    fields[key] ||= value
  end

  # Set value
  def set(key, value)
    key = normalize_key(key)
    fields[key] = value
  end

  # Set value and save to file
  def set!(key, value)
    set(key, value)
    save_file
  end

  def get(key)
    key = normalize_key(key)
    fields[key]
  end

  def save_file
    @fields ||= {}
    ::File.write file_path, fields.to_json
  end

  def load_file
    begin
      @fields = ::JSON.parse(::File.read file_path)
    rescue ::JSON::ParserError
      raise "error on parsing #{file_path}"
    end
  end


  #
  # config helpers
  #

  def file_path
    ::File.join home, "config.json"
  end

  def repository_cache_path
    ::File.join home, "repo_cache"
  end

  def installed_repos_file
    ::File.join home, "installed_repos.yml"
  end

  def install_path
    ::File.join home, "repo"
  end

  def sspm_url
    "#{get :sspm_protocol}://#{get :sspm_host}/api/#{get :sspm_version}"
  end

  def debug?
    get :debug
  end

  def init_directories
    ::FileUtils.mkdir_p home
    ::FileUtils.mkdir_p install_path
    ::FileUtils.mkdir_p repository_cache_path
    ::File.write file_path, {}.to_json unless ::File.exists?(file_path)
  end

  private

  # Key => key
  # :Key => key
  def normalize_key(key)
    key.to_s.downcase
  end

  def load_environment_variables
    ENV_FIELDS.each do |field_sym|
      value = load_env(field_sym)
      set field_sym, value unless value.nil?
    end
  end

  def load_env(sym)
    name = sym.to_s.upcase # :foo_bar => FOO_BAR
    key = "#{ENV_PREFIX}#{name}"
    return nil unless ENV.has_key?(key) && (not ENV[key].nil?)
    if ENV_FLAGS.include?(sym)
      ENV[key] === "true"
    else
      ENV[key]
    end
  end

  def load_options(options)
    options.each do |key, value|
      set key, value
    end
  end

  def resolve_home
    @home ||= ENV["SOCIAL_SNIPPET_HOME"]
    @home ||= ::File.join(ENV["HOME"], ".social-snippet")
  end

end
