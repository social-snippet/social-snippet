module SocialSnippet::CommandLine
    
  class SSpm::SubCommands::UpdateCommand < Command

    def usage
      <<EOF
Usage: sspm update [options] [--] [<repo> ...]

Examples:
    $ sspm update
    -> Update all installed repositories

    $ sspm update example-repo
    -> Update example-repo and Install missing dependencies
EOF
    end

    def desc
      "Update repositories"
    end

    def define_options
    end

    def run
      if has_next_token?
        while has_next_token?
          social_snippet.api.update_repository next_token, options
        end
      else
        social_snippet.api.update_all_repositories options
      end
    end

  end

end
