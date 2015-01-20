module SocialSnippet::CommandLine

  # TODO: $ sspm init --no-prompt
  class SSpm::SubCommands::InitCommand < Command

    def usage
      <<EOF
Usage:
    $ sspm init
    -> Generate snippet.json interactively
EOF
    end

    def desc
      "Generate snippet.json interactively"
    end

    def define_options
    end

    def run
      social_snippet.api.init_manifest options
    end

  end

end
