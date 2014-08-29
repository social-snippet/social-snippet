module SocialSnippet
  class Config
    attr_reader :home

    # Constructor
    def initialize
      load_from_environment_variables
      load_default_value
    end

    # Load environmental variables
    def load_from_environment_variables
      @home = ENV['SOCIAL_SNIPPET_HOME']
    end

    # Load default values
    def load_default_value
      @home ||= "#{ENV['HOME']}/.social-snippet"
    end
  end
end

