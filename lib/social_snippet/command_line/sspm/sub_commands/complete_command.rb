module SocialSnippet::CommandLine

  class SSpm::SubCommands::CompleteCommand < Command

    def usage
      <<EOF
Usage: sspm complete [options] [--] <keyword>
EOF
    end

    def desc
      "Complete snippet paths (for editor plugins)"
    end

    def define_options
    end

    def run
      if has_next_token?
        core.api.cli_complete_snippet_path next_token
      else
        help
      end
    end

  end

end
