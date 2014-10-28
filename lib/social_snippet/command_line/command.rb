#
# Usage:
#
# class SomeCommand < Command; end
# cli = SomeCommand.new [arg1, arg2, ...]
# cli.init
# cli.run
#

module SocialSnippet

  module CommandLine

    class Command

      attr_reader :args
      attr_reader :tokens
      attr_reader :options
      attr_reader :opt_parser
      attr_reader :input

      def initialize(new_args, input = "")
        @args = new_args.clone
        @options = {}
        @tokens = [] # init after parse options
        @opt_parser = OptionParser.new
        @input = input
      end

      def define_options
        raise "not implement"
      end

      def set_default_options
        raise "not implement"
      end

      def init
        define_options
        opt_parser.parse! line_options
        @tokens = extract_tokens
        set_default_options
      end

      def run
        raise "not implement"
      end

      private

      def line_options
        last_ind = args.index do |arg|
          is_not_line_option?(arg)
        end
        if last_ind.nil?
          args
        else
          args[0 .. last_ind]
        end
      end

      # hello -> HelloCommand
      def to_command_class_sym(s)
        "#{s.capitalize}Command".to_sym
      end

      def is_line_option?(s)
        return true if /^-[a-zA-Z0-9]$/ === s
        return true if /^--/ === s
        return false
      end

      def is_not_line_option?(s)
        is_line_option?(s) === false
      end

      def has_subcommand?
        return false if args.empty?
        return false if args[0].start_with?("-")
        return true
      end

      def extract_tokens
        args.select {|arg| is_not_line_option?(arg) }
      end

      # [--opt1, --opt2, token1, token2] => token1
      def next_token
        @tokens.shift
      end

      def say(s)
        puts s
      end

    end

  end

end
