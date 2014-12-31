class SocialSnippet::Config

  attr_reader :social_snippet

  # prefix of environment variables
  ENV_PREFIX = "SOCIAL_SNIPPET_"

  FIELDS = [
    # The path of home directory [default: "$HOME/.social-snippet"]
    :home,
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
  FLAGS = [
    :debug,
  ]

  # set accessors
  FIELDS.each {|field| attr_reader field }

  # Constructor
  def initialize(new_social_snippet, options = {})
    @social_snippet = new_social_snippet

    fields = {}
    fields.merge! options
    load_environment_variables fields

    # set default values
    fields[:home] ||= "#{ENV["HOME"]}/.social-snippet"
    fields[:sspm_host]      ||= "sspm.herokuapp.com"
    fields[:sspm_version]   ||= "v0"
    fields[:sspm_protocol]  ||= "https"

    FIELDS.each do |field_name|
      key = "@#{field_name.to_s}".to_sym
      instance_variable_set key, fields[field_name]
    end

    init_directories
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

  def init_directories
    ::FileUtils.mkdir_p home
    ::FileUtils.mkdir_p install_path
    ::FileUtils.mkdir_p repository_cache_path
  end

  def debug?
    debug
  end

  private

  def load_environment_variables(fields)
    FIELDS.each do |field_sym|
      fields[field_sym] ||= load_env(field_sym)
    end
  end

  def load_env(sym)
    name = sym.to_s.upcase # :foo_bar => FOO_BAR
    key = "#{ENV_PREFIX}#{name}"
    return nil unless ENV.has_key?(key) && (not ENV[key].nil?)
    if FLAGS.include?(sym)
      ENV[key] === "true"
    else
      ENV[key]
    end
  end

end
