require "spec_helper"

module SocialSnippet::CommandLine::Sspm

  describe SubCommands::SearchCommand do

    before do
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_HOST", "api.server"
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_VERSION", "dummy"
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_PROTOCOL", "http"
    end # define constants

    let(:fake_repos) do
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
    end

    context "create instance" do

      describe "$ search repo" do

        let(:instance) { SubCommands::SearchCommand.new(["repo"]) }
        before { instance.init }

        before do
          WebMock
          .stub_request(
            :get,
            "http://api.server/api/dummy/repositories?q=repo",
          )
          .to_return(
            :status => 200,
            :body => fake_repos.to_json,
            :headers => {
              "Content-Type" => "application/json",
            },
          )
        end # GET /repositories?q=repo

        context "run" do

          context "name" do

            it "my-repo" do
              expect { instance.run }.to output(/my-repo/).to_stdout
            end

            it "new-repo" do
              expect { instance.run }.to output(/my-repo/).to_stdout
            end

          end # name

          context "desc" do

            it "my-repo" do
              expect { instance.run }.to output(/my repository/).to_stdout
            end

            it "new-repo" do
              expect { instance.run }.to output(/new repository/).to_stdout
            end

          end # desc

          context "url" do

            it "my-repo" do
              expect { instance.run }.to_not output(/#{"git://github.com/user/my-repo"}/).to_stdout
            end

            it "new-repo" do
              expect { instance.run }.to_not output(/#{"git://github.com/user/new-repo"}/).to_stdout
            end

          end

        end # run

      end # $ search repo

      describe "$ search --name --no-desc repo" do

        let(:instance) { SubCommands::SearchCommand.new(["--name", "--no-desc", "repo"]) }
        before { instance.init }

        before do
          WebMock
          .stub_request(
            :get,
            "http://api.server/api/dummy/repositories?q=repo",
          )
          .to_return(
            :status => 200,
            :body => fake_repos.to_json,
            :headers => {
              "Content-Type" => "application/json",
            },
          )
        end # GET /repositories?q=repo

        context "run" do

          context "name" do

            it "my-repo" do
              expect { instance.run }.to output(/my-repo/).to_stdout
            end

            it "new-repo" do
              expect { instance.run }.to output(/my-repo/).to_stdout
            end

          end # name

          context "no desc" do

            it "my-repo" do
              expect { instance.run }.to_not output(/my repository/).to_stdout
            end

            it "new-repo" do
              expect { instance.run }.to_not output(/new repository/).to_stdout
            end

          end # desc

          context "no url" do

            it "my-repo" do
              expect { instance.run }.to_not output(/#{"git://github.com/user/my-repo"}/).to_stdout
            end

            it "new-repo" do
              expect { instance.run }.to_not output(/#{"git://github.com/user/new-repo"}/).to_stdout
            end

          end

        end # run

      end # $ search --name repo

    end # create instance

  end # SubCommands::SearchCommand

end # SocialSnippet::CommandLine::Sspm

