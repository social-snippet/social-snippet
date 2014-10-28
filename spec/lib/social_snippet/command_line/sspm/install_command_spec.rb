require "spec_helper"

module SocialSnippet::CommandLine::Sspm

  describe SubCommands::InstallCommand do

    before do
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_HOST", "api.server"
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_VERSION", "dummy"
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_PROTOCOL", "http"
    end # define constants

    context "create instance" do

      describe "$ sspm install my-repo" do

        let(:instance) { SubCommands::InstallCommand.new ["my-repo"] }
        before { instance.init }

        let(:result) do
          [
            {
              "name" => "my-repo",
              "desc" => "This is my repository.",
              "url" => "git://github.com/user/my-repo",
            },
            # {
            #   "name" => "new-repo",
            #   "desc" => "This is new repository.",
            #   "url" => "git://github.com/user/new-repo",
            # },
          ]
        end # result

        before do
          WebMock
          .stub_request(
            :get,
            "http://api.server/api/dummy/repositories/my-repo/dependencies",
          )
          .to_return(
            :status => 200,
            :body => result.to_json,
            :headers => {
              "Content-Type" => "application/json",
            },
          )
        end # GET /repositories/my-repo/dependencies

        before do
          expect(::SocialSnippet::Repository).to receive(:clone).once do
            ::SocialSnippet::Repository::BaseRepository.new("/path/to/repo")
          end

          expect_any_instance_of(::SocialSnippet::RepositoryManager).to receive(:install_repository).once do
            true
          end
        end

        context "output" do

          it "my-repo" do
            expect { instance.run }.to output(/Install/).to_stdout
          end

          it "install" do
            expect { instance.run }.to output(/Install/).to_stdout
          end

          it "download" do
            expect { instance.run }.to output(/Download/).to_stdout
          end

          it "success" do
            expect { instance.run }.to output(/Success/).to_stdout
          end

        end # output

      end # $ sspm install my-repo

      describe "$ sspm install new-repo" do

        let(:instance) { SubCommands::InstallCommand.new ["new-repo"] }
        before { instance.init }

        let(:result) do
          [
            {
              "name" => "my-repo",
              "desc" => "This is my repository.",
              "url" => "git://github.com/user/my-repo",
            },
            {
              "name" => "new-repo",
              "desc" => "This is new repository.",
              "url" => "git://github.com/user/new-repo",
            },
          ]
        end # result

        before do
          WebMock
          .stub_request(
            :get,
            "http://api.server/api/dummy/repositories/new-repo/dependencies",
          )
          .to_return(
            :status => 200,
            :body => result.to_json,
            :headers => {
              "Content-Type" => "application/json",
            },
          )
        end # GET /repositories/new-repo/dependencies

        before do
          expect(::SocialSnippet::Repository).to receive(:clone).twice do
            ::SocialSnippet::Repository::BaseRepository.new("/path/to/repo")
          end

          expect_any_instance_of(::SocialSnippet::RepositoryManager).to receive(:install_repository).twice do
            true
          end
        end

        context "output" do

          it "my-repo" do
            expect { instance.run }.to output(/my-repo/).to_stdout
          end

          it "new-repo" do
            expect { instance.run }.to output(/new-repo/).to_stdout
          end

          it "my-repo -> new-repo" do
            expect { instance.run }.to output(/my-repo.*new-repo/m).to_stdout
          end

          it "install" do
            expect { instance.run }.to output(/Install/).to_stdout
          end

          it "download" do
            expect { instance.run }.to output(/Download/).to_stdout
          end

          it "success" do
            expect { instance.run }.to output(/Success/).to_stdout
          end

        end # output

      end # $ sspm install new-repo

      describe "$ sspm install --dry-run new-repo", :current => true do

        let(:instance) { SubCommands::InstallCommand.new ["--dry-run", "new-repo"] }
        before { instance.init }

        let(:result) do
          [
            {
              "name" => "my-repo",
              "desc" => "This is my repository.",
              "url" => "git://github.com/user/my-repo",
            },
            {
              "name" => "new-repo",
              "desc" => "This is new repository.",
              "url" => "git://github.com/user/new-repo",
            },
          ]
        end # result

        before do
          WebMock
          .stub_request(
            :get,
            "http://api.server/api/dummy/repositories/new-repo/dependencies",
          )
          .to_return(
            :status => 200,
            :body => result.to_json,
            :headers => {
              "Content-Type" => "application/json",
            },
          )
        end # GET /repositories/new-repo/dependencies

        before do
          expect(::SocialSnippet::Repository).not_to receive(:clone) do
            ::SocialSnippet::Repository::BaseRepository.new("/path/to/repo")
          end

          expect_any_instance_of(::SocialSnippet::RepositoryManager).not_to receive(:install_repository) do
            true
          end
        end

        context "output" do

          it "my-repo" do
            expect { instance.run }.to output(/my-repo/).to_stdout
          end

          it "new-repo" do
            expect { instance.run }.to output(/new-repo/).to_stdout
          end

          it "my-repo -> new-repo" do
            expect { instance.run }.to output(/my-repo.*new-repo/m).to_stdout
          end

          it "install" do
            expect { instance.run }.to output(/Install/).to_stdout
          end

          it "download" do
            expect { instance.run }.not_to output(/Download/).to_stdout
          end

          it "success" do
            expect { instance.run }.not_to output(/Success/).to_stdout
          end

        end # output

      end # $ sspm install new-repo

    end # create instance

  end # SubCommands::InstallCommand

end # SocialSnippet::CommandLine::Sspm
