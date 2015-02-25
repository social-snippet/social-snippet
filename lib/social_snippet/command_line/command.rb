#
# Usage:
#
# class SomeCommand < Command; end
# cli = SomeCommand.new [arg1, arg2, ...], stream_opts
# cli.init
# cli.run
#
class SocialSnippet::CommandLine::Command

  attr_reader :args
  attr_reader :tokens
  attr_reader :options
  attr_reader :opt_parser
  attr_reader :streams
  attr_reader :input_stream
  attr_reader :output_stream

  def initialize(new_args, new_streams = {})
    @streams        = new_streams
    @input_stream   = streams[:input_stream]  || STDIN
    @output_stream  = streams[:output_stream] || STDOUT
    @args = new_args.clone
    @options = {}
    @tokens = [] # init after parse options
    @opt_parser = ::OptionParser.new
  end

  def core
    @core ||= ::SocialSnippet::Core.new(input_stream, output_stream)
  end

  # Define an option
  #
  # @param name [Symbol] :hello_world => "--hello-world"
  # @param info[:type] :flag or :string
  # @param info[:default] [Any] default value
  # @param info[:short] [Boolean] enable short flag
  def define_option(name, info = {})
    info[:type] ||= :string
    info[:default] ||= nil
    info[:short] ||= false
    long_opt = to_long_option(name, info)
    options[name] = info[:default]
    if info[:short]
      opt_parser.on to_short_option(name, info), long_opt do |v|
        options[name] = v
      end
    else
      opt_parser.on long_opt do |v|
        options[name] = v
      end
    end
  end

  def define_options
    raise "not implement"
  end

  def init
    init_version
    init_banner
    define_options
    parse_line_options
    @tokens = args
  end

  def run
    raise "not implement"
  end

  private

  def help
    opt_parser.parse ["--help"]
  end

  def init_banner
    opt_parser.banner = usage
  end

  def usage
    raise "not implement"
  end

  def init_version
    opt_parser.version = ::SocialSnippet::VERSION
  end

  def to_long_option(sym, info = {})
    if info[:type] == :flag
      "--[no-]#{sym.to_s.gsub("_", "-")}"
    elsif info[:type] == :string
      "--#{sym.to_s.gsub("_", "-")} value"
    else
      "--#{sym.to_s.gsub("_", "-")}"
    end
  end

  def to_short_option(sym, info = {})
    "-#{sym.to_s[0]}"
  end

  def parse_line_options
    return if args.empty?
    last_ind = last_line_option_index
    if last_ind.nil?
      parsed = args.clone
    else
      parsed = args[0 .. last_ind]
    end
    @args = opt_parser.parse(parsed).concat(args[last_ind + 1..-1])
  end

  def last_line_option_index
    args.index do |arg|
      is_not_line_option?(arg)
    end
  end

  # hello -> HelloCommand
  def to_command_class_sym(s)
    "#{s.capitalize}Command".to_sym
  end

  # :HelloCommand -> hello
  def to_command_name(sym)
    sym.to_s.gsub(/Command$/, '').downcase
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

  # [--opt1, --opt2, token1, token2] => token1
  def next_token
    tokens.shift
  end

  def has_next_token?
    not tokens.empty?
  end

end
