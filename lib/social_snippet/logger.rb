require "logger"

class SocialSnippet::Logger < ::Logger

  def say(s)
    @logdev.dev.puts s if info?
  end

end
