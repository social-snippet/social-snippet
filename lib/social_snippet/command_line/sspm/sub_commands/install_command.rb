module SocialSnippet::CommandLine

  require "uri"
  require "pathname"
  require "json"
    
  class SSpm::SubCommands::InstallCommand < Command

    def usage
      <<EOF
Usage: sspm install [options] [--] <repo> [<repo> ...]

    <repo>'s format:
        <name> (e.g. "example-repo")
        <name>#<version> (e.g. "example-repo#0.0.1")

Example:
    $ sspm install example-repo
    -> Installed latest version (or remote's current ref)

    $ sspm install example-repo#0.0.1
    -> Installed as the specified version
EOF
    end

    def desc
      "Install snippet repository"
    end

    def define_options
      define_option :dry_run, :type => :flag, :short => true, :default => false
      define_option :name, :short => true, :default => nil
    end

    def run
      if has_next_token?
        install_by_names
      else
        install_by_snippet_json
      end
    end

    def install_by_snippet_json
      snippet_json = ::JSON.parse(File.read("snippet.json"))
      snippet_json["dependencies"].each do |name, ref|
        social_snippet.api.install_repository_by_name name, ref, options
      end
    end

    def install_by_names
      while has_next_token?
        token_str = next_token
        if is_name?(token_str)
          repo_info = parse_repo_token(token_str)
          social_snippet.api.install_repository_by_name repo_info[:name], repo_info[:ref], options
        elsif is_url?(token_str)
          repo_info = parse_repo_token(token_str)
          repo_url  = repo_info[:name]
          social_snippet.api.install_repository_by_url repo_url, repo_info[:ref], options
        elsif is_path?(token_str)
          repo_info = parse_repo_token(token_str)
          repo_path = repo_info[:name]
          social_snippet.api.install_repository_by_path repo_path, repo_info[:ref], options
        end
      end
    end

    private

    def is_name?(s)
      not /\// === s
    end

    def is_path?(s)
      pathname = ::Pathname.new(s)
      pathname.absolute? || pathname.relative?
    end

    def is_url?(s)
      ::URI::regexp === s
    end

    def parse_repo_token(token_str)
      if has_ref?(token_str)
        words = token_str.split("#", 2)
        {
          :name => words.shift,
          :ref => words.shift,
        }
      else
        {
          :name => token_str,
        }
      end
    end

    def has_ref?(token_str)
      /#/ === token_str
    end

  end

end
