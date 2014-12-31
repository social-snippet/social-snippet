module SocialSnippet::CommandLine

  class SSpm::SubCommands::SearchCommand < Command

    def usage
      <<EOF
Usage: sspm search [options] [--] <keyword>
EOF
    end

    def desc
      "Search for repository by keyword"
    end

    def define_options
      define_option :name, :type => :flag, :short => true, :default => true
      define_option :desc, :type => :flag, :short => true, :default => true
      define_option :url, :type => :flag, :short => true, :default => false
      define_option :installed, :type => :flag, :short => true, :default => true
    end

    def run
      if has_next_token?
        social_snippet.api.search_repositories next_token, options
      else
        help
      end
    end

  end

end
