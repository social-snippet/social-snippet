require "spec_helper"

describe ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand do

  before do
    allow_any_instance_of(
      ::SocialSnippet::Registry::RegistryResources::Base
    ).to receive(:rest_client) do
      ::RestClient::Resource.new "http://api.server/api/dummy"
    end
  end

  describe "$ sspm install" do

    before do
      allow(fake_core.api).to receive(:install_repository).and_return false
      allow(fake_core.api).to receive(:resolve_name_by_registry).and_return false
    end

    context "create snippet.json" do

      before do
        ::FileUtils.touch "snippet.json"
        ::File.write "snippet.json", {
          :dependencies => {
            "foo" => "1.2.3",
            "bar" => "0.0.1"
          },
        }.to_json
      end

      before do
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("foo") do
          "url-foo"
        end
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("bar") do
          "url-bar"
        end
      end

      context "install by snippet.json" do
        let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new [] }
        it { expect(fake_core.api).to receive(:install_repository).with("url-foo", "1.2.3", kind_of(::Hash)).once }
        it { expect(fake_core.api).to receive(:install_repository).with("url-bar", "0.0.1", kind_of(::Hash)).once }
        after do
          install_command.init
          install_command.run
        end
      end

    end # create snippet.json

  end # $ sspm install

  describe "$ sspm install my-repo" do

    context "prepare registry info" do

      before do
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("my-repo") do
          "git://driver.test/user/my-repo"
        end
      end

      context "install my-repo" do
        let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new ["my-repo"] }
        it { expect(fake_core.api).to receive(:install_repository).with("git://driver.test/user/my-repo", nil, kind_of(::Hash)) }
        after do
          install_command.init
          install_command.run
        end
      end

    end # prepare registry info

  end # $ sspm install my-repo

  describe "package dependencies" do

    context "prepare registry info" do

      before do
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("my-repo") do
          "git://driver.test/user/my-repo"
        end
        allow(fake_core.api).to receive(:resolve_name_by_registry).with("new-repo") do
          "git://driver.test/user/new-repo"
        end
      end

      context "install new-repo" do
        let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new ["new-repo"] }
        example do
          expect(fake_core.repo_manager).to receive(:install).with("git://driver.test/user/my-repo", "1.2.3", kind_of(::Hash)).once do
            ::SocialSnippet::Repository::Models::Package.new
          end
          expect(fake_core.repo_manager).to receive(:install).with("git://driver.test/user/new-repo", nil, kind_of(::Hash)).once do
            pkg = ::SocialSnippet::Repository::Models::Package.new
            pkg.add_dependency "my-repo", "1.2.3"
            pkg
          end
        end
        after do
          install_command.init
          install_command.run
        end
      end

    end # prepare registry info

  end

end # ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand

