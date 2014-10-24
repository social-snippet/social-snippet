module SocialSnippet

  module CommandLine

    module Sspm

      class MainCommand < Command

        attr_reader :sub_commands

        def initialize(new_args)
          super
          @sub_commands = SubCommands.all.freeze
        end

        def define_options
        end

        def set_default_options
        end

        def run
          if has_subcommand?
            command_name = @args.shift
            call_subcommand command_name
          else
            Sspm.show_usage
          end
        end

        private

        def call_subcommand(name)
          sub_command = to_command_class_sym(name)

          if sub_commands.include?(sub_command)
            cli = Sspm::SubCommands.const_get(sub_command).new(args)
            cli.init
            cli.run
          else
            Sspm::SubCommands.show_usage
          end
        end

      end

    end

  end

end
