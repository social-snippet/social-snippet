class SocialSnippet::Core

  attr_reader :input_stream
  attr_reader :output_stream
  attr_reader :repo_manager
  attr_reader :driver_factory
  attr_reader :config
  attr_reader :registry_client
  attr_reader :logger
  attr_reader :api
  attr_reader :prompt
  attr_reader :storage

  # Constructor
  def initialize(new_input_stream = STDIN, new_output_stream = STDOUT)
    @input_stream   = new_input_stream
    @output_stream  = new_output_stream
    @storage = ::SocialSnippet::Storage.new
    @config = ::SocialSnippet::Config.new(self)
    @logger = ::SocialSnippet::Logger.new output_stream
    @prompt = ::HighLine.new(input_stream, output_stream)
    init_logger

    init_yaml_document
    ::SocialSnippet::Repository::Models::Package.core = self
    ::SocialSnippet::Repository::Models::Repository.core = self
    @repo_manager = ::SocialSnippet::Repository::RepositoryManager.new(self)
    @driver_factory = ::SocialSnippet::Repository::DriverFactory.new(self)
    @registry_client = ::SocialSnippet::Registry::RegistryClient.new(self)
    @api = ::SocialSnippet::Api.new(self)
  end

  def init_yaml_document
    if ::SocialSnippet::Document == ::SocialSnippet::DocumentBackend::YAMLDocument
      ::SocialSnippet::DocumentBackend::YAMLDocument.set_path config.document_path
    end
  end

  def init_logger
    logger.level = ::SocialSnippet::Logger::Severity::INFO
    logger.level = ::SocialSnippet::Logger::Severity::DEBUG if config.debug?
  end

end # SocialSnippet

