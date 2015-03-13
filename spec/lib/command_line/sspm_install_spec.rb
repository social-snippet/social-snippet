require "spec_helper"

describe ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand, :current => true do

  before do
    allow_any_instance_of(
      ::SocialSnippet::Registry::RegistryResources::Base
    ).to receive(:rest_client) do
      ::RestClient::Resource.new "http://api.server/api/dummy"
    end
  end

  before do
    my_repo_info = {
      "name" => "my-repo",
      "desc" => "This is new repository.",
      "url" => "git://driver.test/user/my-repo",
      "dependencies" => {
      },
    }

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
  end # GET /repositories/my-repo

  before do
    allow(fake_core.api).to receive(:install_repository).and_return false
    allow(fake_core.api).to receive(:resolve_name_by_registry).and_return false
  end

  before do
    allow(fake_core.api).to receive(:resolve_name_by_registry).with("my-repo") do
      "git://driver.test/user/my-repo"
    end
  end

  describe "$ sspm install" do

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

    let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new ["my-repo"] }
    it { expect(fake_core.api).to receive(:install_repository).with("git://driver.test/user/my-repo", nil, kind_of(::Hash)) }
    after do
      install_command.init
      install_command.run
    end

  end # $ sspm install my-repo

end # ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand

