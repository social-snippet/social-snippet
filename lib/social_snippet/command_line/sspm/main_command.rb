module SocialSnippet::CommandLine

  class SSpm::MainCommand < Command

    attr_reader :sub_commands

    def initialize(new_args, new_streams = {})
      super
      @sub_commands = SSpm::SubCommands.all
    end

    def define_options
    end

    def usage
      <<EOF
Usage: sspm <command> [options] [--]

Commands:
#{usage_subcommands}
EOF
    end

    def run
      if has_subcommand?
        command_name = args.shift
        find_subcommand command_name
      else
        help
      end
    end

    private

    def usage_subcommands
      sub_commands.sort.map do |sub_command_sym|
        {
          :sym => sub_command_sym,
          :instance => SSpm::SubCommands.const_get(sub_command_sym).new(args),
        }
      end.map do |sub_command|
        "    #{to_command_name(sub_command[:sym])}\t#{sub_command[:instance].desc}"
      end.join("\n")
    end

    def find_subcommand(command_name)
      sub_command_sym = to_command_class_sym(command_name)
      if sub_commands.include?(sub_command_sym)
        call_subcommand(sub_command_sym)
      else
        help
      end
    end

    def call_subcommand(sym)
      cli = SSpm::SubCommands.const_get(sym).new(args)
      cli.init
      cli.run
    end

  end

end
