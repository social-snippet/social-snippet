require "spec_helper"

module SocialSnippet

  describe RegistryClient do

    # enable WebMock
    before { WebMock.disable_net_connect! }

    # enable FakeFS
    before { FakeFS.activate! }
    after { FakeFS.deactivate!; FakeFS::FileSystem.clear }

    let(:fake_repos) do
      [
        {
          "name" => "my-repo",
          "desc" => "This is my repository.",
        },
        {
          "name" => "new-repo",
          "desc" => "This is my repository.",
        },
      ]
    end

    before do
      WebMock
        .stub_request(
          :get,
          "http://api.server/api/v0/repositories",
        )
        .to_return(
          :status => 200,
          :body => fake_repos.to_json,
          :headers => {
            "Content-Type" => "application/json",
          },
        )
    end # GET /api/v0/repositories

    before do
      WebMock
        .stub_request(
          :get,
          /http:\/\/api\.server\/api\/v0\/repositories\?q=/
        )
        .to_return do |req|
          params = CGI.parse(req.uri.query)
          {
            :status => 200,
            :body => fake_repos.select {|repo|
              /#{params["q"][0]}/ === repo["name"]
            }.to_json,
            :headers => {
              "Content-Type" => "application/json",
            },
          }
        end
    end # GET /api/v0/repositories?q=...

    after do
      WebMock.reset!
    end

    context "create instance" do

      let(:instance) { RegistryClient.new("api.server", "v0") }

      context "get_repositories" do

        let(:result) { instance.get_repositories }

        context "check result" do
          let(:result_names) { result.map {|repo| repo["name"] } }
          it { expect(result.length).to eq 2 }
          it { expect(result_names).to include "my-repo" }
          it { expect(result_names).to include "new-repo" }
        end

      end # get_repositories

      context "get_repositories with query" do

        context "query = repo" do

          let(:result) { instance.get_repositories("repo") }

          context "check" do
            let(:result_names) { result.map {|repo| repo["name"] } }
            it { expect(result.length).to eq 2 }
            it { expect(result_names).to include "my-repo" }
            it { expect(result_names).to include "new-repo" }
          end # check

        end # query = repo

        context "query = new" do

          let(:result) { instance.get_repositories("new") }

          context "check" do
            let(:result_names) { result.map {|repo| repo["name"] } }
            it { expect(result.length).to eq 1 }
            it { expect(result_names).to_not include "my-repo" }
            it { expect(result_names).to include "new-repo" }
          end

        end

      end # get_repositories with query

    end # create instance

  end # RegistryClient

end # SocialSnippet
