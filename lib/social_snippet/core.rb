class SocialSnippet::Core

  attr_reader :input_stream
  attr_reader :output_stream
  attr_reader :repo_manager
  attr_reader :config
  attr_reader :registry_client
  attr_reader :logger
  attr_reader :api
  attr_reader :prompt

  # Constructor
  def initialize(new_input_stream = STDIN, new_output_stream = STDOUT)
    @input_stream   = new_input_stream
    @output_stream  = new_output_stream
    @config = ::SocialSnippet::Config.new(self)
    @logger = ::SocialSnippet::Logger.new output_stream
    @prompt = ::HighLine.new(input_stream, output_stream)
    init_logger

    @repo_manager = ::SocialSnippet::Repository::RepositoryManager.new(self)
    @registry_client = ::SocialSnippet::Registry::RegistryClient.new(self)
    @api = ::SocialSnippet::Api.new(self)
  end

  def init_logger
    logger.level = ::SocialSnippet::Logger::Severity::INFO
    logger.level = ::SocialSnippet::Logger::Severity::DEBUG if config.debug?
  end

end # SocialSnippet

