require "spec_helper"

describe ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand do

  before do
    allow_any_instance_of(
      ::SocialSnippet::Registry::RegistryResources::Base
    ).to receive(:rest_client) do
      ::RestClient::Resource.new "http://api.server/api/dummy"
    end
  end

  let(:spy_api) do
    double "api", {
      :on => nil,
      :install_repository => nil,
    }
  end

  before do
    allow(spy_api).to receive(:resolve_name_by_registry).with("foo") do
      "url-foo"
    end
    allow(spy_api).to receive(:resolve_name_by_registry).with("bar") do
      "url-bar"
    end
  end # prepare spy_api

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

      context "prepare command" do

        let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new [] }

        before do
          allow(fake_core).to receive(:api).and_return spy_api
        end

        context "run command" do

          before do
            install_command.init
            install_command.run
          end

          it { expect(spy_api).to have_received(:install_repository).with("url-foo", "1.2.3", kind_of(::Hash)).once }
          it { expect(spy_api).to have_received(:install_repository).with("url-bar", "0.0.1", kind_of(::Hash)).once }

          context "re-install" do

            let(:re_install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new [] }

            before do
              re_install_command.init
              re_install_command.run
            end

            it { expect(spy_api).to have_received(:install_repository).with("url-foo", "1.2.3", kind_of(::Hash)).twice }
            it { expect(spy_api).to have_received(:install_repository).with("url-bar", "0.0.1", kind_of(::Hash)).twice }

          end # re-install

        end # run command

      end # prepare command

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

      context "already installed my-repo" do

        before do
          repo = ::SocialSnippet::Repository::Models::Repository.find_or_create_by(:name => "my-repo")
          repo.add_ref "1.2.3", "rev-1.2.3"
          ::SocialSnippet::Repository::Models::Package.create(
            :repo_name => "my-repo",
            :rev_hash => "rev-1.2.3",
          )
        end

        context "prepare args" do

          let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new ["new-repo"] }

          context "prepare stubs" do

            before do
              expect(fake_core.repo_manager).to_not receive(:install).with("git://driver.test/user/my-repo", "1.2.3", kind_of(::Hash))
              expect(fake_core.repo_manager).to receive(:install).with("git://driver.test/user/new-repo", nil, kind_of(::Hash)).once do
                pkg = ::SocialSnippet::Repository::Models::Package.new
                pkg.add_dependency "my-repo", "1.2.3"
                pkg
              end
            end

            context "install new-repo" do
              subject!(:result) do
                lambda do
                  install_command.init
                  install_command.run
                end
              end
              it { should_not raise_error }
            end

          end # prepare stubs

        end # prepare args

      end # already installed my-repo

      context "prepare args" do

        let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new ["new-repo"] }

        context "prepare stubs" do

          before do
            expect(fake_core.repo_manager).to receive(:install).with("git://driver.test/user/my-repo", "1.2.3", kind_of(::Hash)).once do
              ::SocialSnippet::Repository::Models::Repository.find_or_create_by :name => "my-repo"
              ::SocialSnippet::Repository::Models::Package.create(
                :repo_name => "my-repo",
                :rev_hash => "rev-1.2.3",
              )
            end
            expect(fake_core.repo_manager).to receive(:install).with("git://driver.test/user/new-repo", nil, kind_of(::Hash)).once do
              pkg = ::SocialSnippet::Repository::Models::Package.new
              pkg.add_dependency "my-repo", "1.2.3"
              pkg
            end
          end

          context "install new-repo" do
            subject!(:result) do
              lambda do
                install_command.init
                install_command.run
              end
            end
            it { should_not raise_error }
          end

        end # prepare stubs

      end # prepare args

    end # prepare registry info

  end

end # ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand

