module SocialSnippet::Api::ConfigApi

  # $ sspm config key=value
  def config_set(key, value)
    core.config.set! key, value
  end

  # $ sspm config key
  def config_get(key)
    value = core.config.get(key)
    core.logger.say "#{key}=#{value}"
  end

end
