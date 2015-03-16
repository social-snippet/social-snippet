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
      allow(fake_core.api).to receive(:resolve_name_by_registry).with("foo") do
        "url-foo"
      end
      allow(fake_core.api).to receive(:resolve_name_by_registry).with("bar") do
        "url-bar"
      end
    end # prepare fake_core.api

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

        context "run command" do

          before do
            allow(fake_core.api).to receive(:install_repository)
          end

          before do
            install_command.init
            install_command.run
          end

          it { expect(fake_core.api).to have_received(:install_repository).with("url-foo", "1.2.3", kind_of(::Hash)).once }
          it { expect(fake_core.api).to have_received(:install_repository).with("url-bar", "0.0.1", kind_of(::Hash)).once }

          context "re-install" do

            let(:re_install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new [] }

            before do
              re_install_command.init
              re_install_command.run
            end

            it { expect(fake_core.api).to have_received(:install_repository).with("url-foo", "1.2.3", kind_of(::Hash)).twice }
            it { expect(fake_core.api).to have_received(:install_repository).with("url-bar", "0.0.1", kind_of(::Hash)).twice }

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

      before do
        allow(fake_core.api).to receive(:install_repository)
      end

      context "prepare command" do
        let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new ["my-repo"] }
        before { install_command.init }
        context "run command" do
          before { install_command.run }
          it { expect(fake_core.api).to have_received(:install_repository).with("git://driver.test/user/my-repo", nil, kind_of(::Hash)).once }
        end
      end # prepare command

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
          repo.add_package "1.2.3"
          ::SocialSnippet::Repository::Models::Package.create(
            :repo_name => "my-repo",
            :rev_hash => "rev-1.2.3",
          )
        end

        context "install new-repo" do

          let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new ["new-repo"] }
          before { install_command.init }

          context "prepare stubs" do

            before do
              allow(fake_core.repo_manager).to receive(:install).with("git://driver.test/user/new-repo", nil, kind_of(::Hash)).once do
                pkg = ::SocialSnippet::Repository::Models::Package.new
                pkg.add_dependency "my-repo", "1.2.3"
                pkg
              end
            end

            before do
              allow(fake_core.api).to receive(:install_repository).and_call_original
            end

            context "run-command" do
              before { install_command.run }
              it { expect(fake_core.api).to_not have_received(:install_repository).with("git://driver.test/user/my-repo", "1.2.3", kind_of(::Hash)) }
              it { expect(fake_core.api).to have_received(:install_repository).with("git://driver.test/user/new-repo", nil, kind_of(::Hash)).once }
            end

          end # prepare stubs

        end # prepare args

      end # already installed my-repo

      context "prepare args" do

        let(:install_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand.new ["new-repo"] }
        before { install_command.init }

        context "prepare stubs" do

          before do
            allow(fake_core.repo_manager).to receive(:install).with("git://driver.test/user/my-repo", "1.2.3", kind_of(::Hash)).once do
              ::SocialSnippet::Repository::Models::Repository.find_or_create_by :name => "my-repo"
              ::SocialSnippet::Repository::Models::Package.create(
                :repo_name => "my-repo",
                :rev_hash => "rev-1.2.3",
              )
            end
            allow(fake_core.repo_manager).to receive(:install).with("git://driver.test/user/new-repo", nil, kind_of(::Hash)).once do
              pkg = ::SocialSnippet::Repository::Models::Package.new
              pkg.add_dependency "my-repo", "1.2.3"
              pkg
            end
          end

          before do
            allow(fake_core.api).to receive(:install_repository).and_call_original
          end

          context "run-command" do
            before { install_command.run }
            it { expect(fake_core.api).to have_received(:install_repository).with("git://driver.test/user/my-repo", "1.2.3", kind_of(::Hash)).once }
            it { expect(fake_core.api).to have_received(:install_repository).with("git://driver.test/user/new-repo", nil, kind_of(::Hash)).once }
          end

        end # prepare stubs

      end # prepare args

    end # prepare registry info

  end

end # ::SocialSnippet::CommandLine::SSpm::SubCommands::InstallCommand

