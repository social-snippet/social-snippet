module SocialSnippet::SpecHelpers

  class FakeCore; end

  def fake_storage
    @fake_storage ||= ::SocialSnippet::Storage.new
  end

  def fake_io
    @fake_io ||= ::StringIO.new
  end

  def fake_logger
    reset_fake_logger unless @logger
    @logger
  end

  def reset_fake_logger
    @logger = ::SocialSnippet::Logger.new(fake_io)
    @logger.level = ::SocialSnippet::Logger::Severity::INFO
  end

  def fake_home
    reset_fake_home unless @tmp_path
    @tmp_path
  end

  def reset_fake_home
    tmp_root = ::File.join(::Dir.tmpdir, "social_snippet")
    ::FileUtils.mkdir_p tmp_root
    @tmp_path = ::Dir.mktmpdir(nil, tmp_root)
  end

  def make_fake_home
    fake_config.init_filesystem
  end

  def global_config
    $social_snippet_config ||= ::SocialSnippet::Config.new(
      fake_core,
      {
        :home => fake_home,
        :sspm_host => "api.server",
      },
    )
  end

  def enable_global_config
    @enable_global_config = true
  end

  def fake_config
    @config ||= ::SocialSnippet::Config.new(
      fake_core,
      {
        :home => fake_home,
        :sspm_host => "api.server",
      },
    )
  end

  def fake_api
    @fake_api ||= ::SocialSnippet::Api.new(fake_core)
  end

  def fake_core
    reset_fake_core unless @fake_core
    @fake_core
  end

  def fake_repo_manager
    @fake_repo_manager ||= ::SocialSnippet::Repository::RepositoryManager.new(fake_core)
  end

  def fake_driver_factory
    @fake_driver_factory ||= ::SocialSnippet::Repository::DriverFactory.new(fake_core)
  end

  def fake_registry_client
    @fake_registry_client ||= ::SocialSnippet::Registry::RegistryClient.new(fake_core)
  end

  def reset_fake_core
    @fake_core = FakeCore.new
    ::SocialSnippet::Repository::Models::Package.core = fake_core
    ::SocialSnippet::Repository::Models::Repository.core = fake_core
    allow(fake_core).to receive(:storage).and_return fake_storage
    allow(fake_core).to receive(:logger).and_return fake_logger
    allow(fake_core).to receive(:config).and_return fake_config
    allow(fake_core).to receive(:api).and_return fake_api
    allow(fake_core).to receive(:repo_manager).and_return fake_repo_manager
    allow(fake_core).to receive(:driver_factory).and_return fake_driver_factory
    allow(fake_core).to receive(:registry_client).and_return fake_registry_client
    allow_any_instance_of(::SocialSnippet::CommandLine::Command).to receive(:core).and_return fake_core
  end

end

module SocialSnippet
  ::RSpec.configure do |config|
    config.include SpecHelpers
    config.before { reset_fake_core }
    config.before { fake_core.driver_factory.reset_drivers }
  end

  # setup yaml document
  ::RSpec.configure do |config|
    config.before do
      if ::SocialSnippet::Document == ::SocialSnippet::DocumentBackend::YAMLDocument
        document_path = ::File.join(::Dir.mktmpdir, "document.yml")
        $yaml_document_hash = nil
        ::FileUtils.rm document_path if ::File.exists?(document_path)
        ::SocialSnippet::DocumentBackend::YAMLDocument.set_path document_path
      end
    end
  end
end
