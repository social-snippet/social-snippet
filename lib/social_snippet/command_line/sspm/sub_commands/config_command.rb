module SocialSnippet::CommandLine

  class SSpm::SubCommands::ConfigCommand < Command

    def usage
      <<EOF
Usage:
    $ sspm config <key>
    -> show <value>

    $ sspm config <key>=<value>
    $ sspm config <key> <value>
    -> set <value> to key
EOF
    end

    def desc
      "Manage configuration"
    end

    def define_options
    end

    def run
      if has_next_token?
        s = next_token
        if has_next_token?
          key = s
          value = next_token
          social_snippet.api.config_set key, value
        else
          if has_value?(s)
            key, value = s.split("=")
            social_snippet.api.config_set key, value
          else
            key = s
            social_snippet.api.config_get key
          end
        end
      else
        usage
      end
    end

    private

    def has_value?(s)
      /=/ === s
    end

  end

end
