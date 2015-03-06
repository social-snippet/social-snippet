require "spec_helper"

module SocialSnippet::CommandLine

  describe SSpm::SubCommands::InstallCommand do

    before do
      allow_any_instance_of(
        ::SocialSnippet::Registry::RegistryResources::Base
      ).to receive(:rest_client) do
        ::RestClient::Resource.new "http://api.server/api/dummy"
      end
    end

    let(:my_repo_info) do
      {
        "name" => "my-repo",
        "desc" => "This is new repository.",
        "url" => "git://github.com/user/my-repo",
        "dependencies" => {
        },
      }
    end # result

    before do
      WebMock
        .stub_request(
          :get,
          "http://api.server/api/dummy/repositories/my-repo",
        )
        .to_return(
          :status => 200,
          :body => my_repo_info.to_json,
          :headers => {
            "Content-Type" => "application/json",
          },
        )
    end # GET /repositories/my-repo/dependencies

    let(:new_repo_info) do
      {
        "name" => "new-repo",
        "desc" => "This is new repository.",
        "url" => "git://github.com/user/new-repo",
        "dependencies" => {
          "my-repo" => "1.0.0",
        },
      }
    end # result

    before do
      WebMock
        .stub_request(
          :get,
          "http://api.server/api/dummy/repositories/new-repo",
        )
        .to_return(
          :status => 200,
          :body => new_repo_info.to_json,
          :headers => {
            "Content-Type" => "application/json",
          },
        )
    end # GET /repositories/new-repo/dependencies

    before do
      allow(fake_core.repo_factory).to receive(:clone).with(/my-repo/) do |url|
        class FakeRepo
          attr_reader :path
        end

        repo = FakeRepo.new
        allow(repo).to receive(:path).and_return "/path/to/my-repo"
        allow(repo).to receive(:name).and_return "my-repo"
        allow(repo).to receive(:create_cache).and_return ""
        allow(repo).to receive(:has_versions?).and_return true
        allow(repo).to receive(:latest_version).and_return "1.2.3"
        allow(repo).to receive(:dependencies).and_return({})
        repo
      end
    end # prepare my-repo

    before do
      allow(fake_core.repo_factory).to receive(:clone).with(/new-repo/) do |url|
        class FakeRepo
          attr_reader :path
        end

        repo = FakeRepo.new
        allow(repo).to receive(:path).and_return "/path/to/new-repo"
        allow(repo).to receive(:name).and_return "new-repo"
        allow(repo).to receive(:create_cache).and_return ""
        allow(repo).to receive(:has_versions?).and_return true
        allow(repo).to receive(:latest_version).and_return "1.2.4"
        allow(repo).to receive(:dependencies).and_return new_repo_info["dependencies"]
        repo
      end
    end # prepare new-repo

    before do
      allow(::FileUtils).to receive(:cp_r) do
        # do nothing
      end
    end

    #
    # main
    #
    let(:install_command_output) { ::StringIO.new }
    let(:install_command_logger) { ::SocialSnippet::Logger.new install_command_output }
    before { allow(fake_core).to receive(:logger).and_return install_command_logger }

    describe "$ sspm install" do

      context "create snippet.json" do

        before do
          FileUtils.touch "snippet.json"
          File.write "snippet.json", {
            :dependencies => {
              "foo" => "1.2.3",
              "bar" => "0.0.1"
            },
          }.to_json
        end

        example do
          install_command = SSpm::SubCommands::InstallCommand.new([])
          expect(fake_core.api).to receive(:install_repository_by_name).with("foo", "1.2.3", kind_of(Hash)).once
          expect(fake_core.api).to receive(:install_repository_by_name).with("bar", "0.0.1", kind_of(Hash)).once
          install_command.run
        end

      end # create snippet.json

    end # $ sspm install

    describe "$ sspm install my-repo" do

      let(:install_command_output) { ::StringIO.new }
      let(:install_command_logger) { ::SocialSnippet::Logger.new install_command_output }

      before do
        install_command_logger.level = ::SocialSnippet::Logger::Severity::INFO
        allow(fake_core).to receive(:logger).and_return install_command_logger
        install_command = SSpm::SubCommands::InstallCommand.new ["my-repo"]
        install_command.init
        install_command.run
      end

      subject { install_command_output.string }
      it { should match(/my-repo/) }
      it { should match(/Installing/) }
      it { should match(/Cloning/) }
      it { should match(/Success/) }
      it { should_not match(/dependencies/) }

      context "$ sspm install my-repo (second)" do

        let(:second_install_command_output) { ::StringIO.new }
        let(:second_install_command_logger) { ::SocialSnippet::Logger.new second_install_command_output }

        subject do
          install_command_logger.level = ::SocialSnippet::Logger::Severity::INFO
          allow(fake_core).to receive(:logger).and_return second_install_command_logger
          install_command = SSpm::SubCommands::InstallCommand.new ["my-repo"]
          install_command.init
          install_command.run
          second_install_command_output.string
        end

        it { should match(/my-repo/) }
        it { should_not match(/Installing/) }
        it { should_not match(/Cloning/) }
        it { should_not match(/Success/) }
        it { should_not match(/dependencies/) }

      end # (reinstall) $ sspm install my-repo

    end # $ sspm install my-repo

    describe "$ sspm install new-repo" do

      before do
        install_command = SSpm::SubCommands::InstallCommand.new ["new-repo"]
        install_command.init
        install_command.run
      end

      subject { install_command_output.string }
      it { should match(/my-repo/) }
      it { should match(/new-repo/) }
      it { should match(/my-repo.*new-repo/m) }
      it { should match(/Installing: new-repo#1.2.4/) }
      it { should match(/Installing: my-repo#1.0.0/) }
      it { should match(/Cloning/) }
      it { should match(/Success/) }
      it { should match(/Finding new-repo#1.2.4's/) }

    end # $ sspm install new-repo

    describe "$ sspm install --dry-run new-repo" do

      before do
        install_command = SSpm::SubCommands::InstallCommand.new ["--dry-run", "new-repo"]
        install_command.init
        install_command.run
      end

      subject { install_command_output.string }
      it { should match(/my-repo/) }
      it { should match(/new-repo/) }
      it { should match(/new-repo.*my-repo/m) }
      it { should match(/Installing: new-repo#1.2.4/) }
      it { should match(/Installing: my-repo#1.0.0/) }
      it { should match(/Cloning/) }
      it { should match(/Finding new-repo#1.2.4's/) }
      it { should match(/Success/) }

    end # $ sspm install new-repo

  end # SSpm::SubCommands::InstallCommand

end # SocialSnippet::CommandLine
