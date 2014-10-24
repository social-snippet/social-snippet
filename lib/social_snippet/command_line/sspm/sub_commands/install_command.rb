module SocialSnippet

  module CommandLine
    
    module Sspm

      module SubCommands

        class InstallCommand < Command

          attr_reader :social_snippet
          attr_reader :client

          def initialize(new_args)
            super

            @social_snippet = ::SocialSnippet::SocialSnippet.new

            @client = ::SocialSnippet::RegistryClient.new(
              SSPM_API_HOST,
              SSPM_API_VERSION,
              SSPM_API_PROTOCOL,
            )
          end

          def define_options
            # Does not install
            opt_parser.on "-d", "--dry-run" do
              options[:dry_run] = true
            end
          end

          def set_default_options
            options[:dry_run] if options[:dry_run].nil?
          end

          def run
            repo_name = next_token
            client.get_dependencies(repo_name).each do |repo_info|
              say "Install: #{repo_info["name"]}"

              next if options[:dry_run]

              say "Download: #{repo_info["url"]}"
              repo = Repository.clone repo_info["url"]

              say "Copy: #{repo.path}"
              social_snippet.install_repository repo

              say "Success: #{repo_info["name"]}"
            end

          end

        end

      end

    end

  end

end
