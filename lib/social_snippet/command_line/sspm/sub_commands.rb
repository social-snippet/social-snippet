require_relative "sub_commands/search_command"
require_relative "sub_commands/install_command"

module SocialSnippet

  module CommandLine

    module Sspm

      module SubCommands

        def self.all
          SubCommands.constants.select do |name|
            /.+Command$/ === name
          end
        end

      end

    end

  end

end
