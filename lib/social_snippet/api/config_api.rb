module SocialSnippet::Api::ConfigApi

  # $ sspm config key=value
  def config_set(key, value)
    social_snippet.config.set! key, value
  end

  # $ sspm config key
  def config_get(key)
    value = social_snippet.config.get(key)
    social_snippet.logger.say "#{key}=#{value}"
  end

end
