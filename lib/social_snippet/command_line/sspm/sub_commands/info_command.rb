module SocialSnippet::CommandLine
    
  class SSpm::SubCommands::InfoCommand < Command

    def usage
      <<EOF
Usage: sspm info [options] [--] <repo>
EOF
    end

    def desc
      "Show information of a repository"
    end

    def define_options
    end

    def run
      if has_next_token?
        social_snippet.api.show_info next_token
      else
        help
      end
    end

  end

end
