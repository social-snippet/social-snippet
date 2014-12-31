module SocialSnippet::CommandLine

  class SSpm::SubCommands::PublishCommand < Command

    def usage
      <<EOF
Usage:
    - sspm publish [options] [--] <repo-url>
    - sspm publish [options] [--] <owner-id> <repo-id>
    (published as "https://github.com/{owner-id}/{repo-id}.git")

Example:
    $ sspm publish https://github.com/user/repo
    -> published as the name written in snippet.json

    [another method]
    $ sspm publish user repo

Note:
    - Currently the registry system supported the GitHub repositories only.

EOF
    end

    def desc
      "Publish a repository to the registry system"
    end

    def define_options
    end

    def run
      if has_next_token?
        repo_url = next_token
        if /^(git|http|https)\:\/\// === repo_url # url
          social_snippet.api.add_url repo_url
        elsif has_next_token? # {repo_owner_id} {repo_id}
          owner_id  = repo_url
          repo_id   = next_token
          social_snippet.api.add_url "https://github.com/#{owner_id}/#{repo_id}.git"
        else
          help
        end
      else
        help
      end
    end

  end

end
