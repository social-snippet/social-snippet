require "spec_helper"

module SocialSnippet::CommandLine

  describe SSpm::SubCommands::SearchCommand do

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

    before do
      allow_any_instance_of(::SocialSnippet::Registry::RegistryResources::Base).to receive(:rest_client) do
        RestClient::Resource.new "http://api.server/api/dummy"
      end
    end

    context "create instance" do

      let(:search_command_output) { ::StringIO.new }
      let(:search_command_logger) { ::SocialSnippet::Logger.new search_command_output }
      before { allow(fake_social_snippet).to receive(:logger).and_return search_command_logger }

      describe "$ search repo" do

        let(:search_command) { SSpm::SubCommands::SearchCommand.new(["repo"]) }
        before { search_command.init }

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

          before { search_command.run }

          context "name" do

            it "my-repo" do
              expect(search_command_output.string).to match(/my-repo/)
            end

            it "new-repo" do
              expect(search_command_output.string).to match(/my-repo/)
            end

          end # name

          context "desc" do

            it "my-repo" do
              expect(search_command_output.string).to match(/my repository/)
            end

            it "new-repo" do
              expect(search_command_output.string).to match(/new repository/)
            end

          end # desc

          context "url" do

            it "my-repo" do
              expect(search_command_output.string).to_not match(/#{"git://github.com/user/my-repo"}/)
            end

            it "new-repo" do
              expect(search_command_output.string).to_not match(/#{"git://github.com/user/new-repo"}/)
            end

          end

        end # run

      end # $ search repo

      describe "$ search --name --no-desc repo" do

        let(:search_command) { SSpm::SubCommands::SearchCommand.new(["--name", "--no-desc", "repo"]) }
        before { search_command.init }

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

          before { search_command.run }

          context "name" do

            it "my-repo" do
              expect(search_command_output.string).to match(/my-repo/)
            end

            it "new-repo" do
              expect(search_command_output.string).to match(/my-repo/)
            end

          end # name

          context "no desc" do

            it "my-repo" do
              expect(search_command_output.string).to_not match(/my repository/)
            end

            it "new-repo" do
              expect(search_command_output.string).to_not match(/new repository/)
            end

          end # desc

          context "no url" do

            it "my-repo" do
              expect(search_command_output.string).to_not match(/#{"git://github.com/user/my-repo"}/)
            end

            it "new-repo" do
              expect(search_command_output.string).to_not match(/#{"git://github.com/user/new-repo"}/)
            end

          end

        end # run

      end # $ search --name repo

    end # create instance

  end # SSpm::SubCommands::SearchCommand

end # SocialSnippet::CommandLine::Sspm

