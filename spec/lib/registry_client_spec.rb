require "spec_helper"

module SocialSnippet

  describe Registry::RegistryClient do

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

    let(:config) do
      config = Config.new(
        social_snippet,
        {
          :sspm_host => "api.server",
          :sspm_version => "v0",
          :sspm_protocol => "http",
        }
      )
    end

    def logger
      ::Logger.new(::StringIO.new)
    end

    let(:social_snippet) do
      class Fake; end
      Fake.new
    end

    before do
      allow(social_snippet).to receive(:config).and_return config
      allow(social_snippet).to receive(:logger).and_return logger
    end

    before do
      WebMock
        .stub_request(
          :post,
          "http://api.server/api/v0/repositories",
        )
        .with(
          :headers => {
            "X-CSRF-TOKEN" => "fake-token",
          },
        )
        .to_return(
          :status => 200,
          :body => "ok",
          :headers => {
            "Content-Type" => "plain/text",
          },
        )
    end # POST /api/v0/repositories

    before do
      WebMock
        .stub_request(
          :get,
          "http://api.server/api/v0/token",
        )
        .to_return(
          :status => 200,
          :body => "fake-token",
          :headers => {
            "Content-Type" => "plain/text",
          },
        )
    end # GET /api/v0/token

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

    context "create registry_client" do

      let(:registry_client) { Registry::RegistryClient.new(social_snippet) }

      context "add repository" do

        let(:result) { registry_client.repositories.add_url "git://github.com/user/repo" }
        it { expect(result).to eq "ok" }

      end # add repository

      context "repositories" do

        let(:result) { registry_client.repositories.all }

        context "check result" do
          let(:result_names) { result.map {|repo| repo["name"] } }
          it { expect(result.length).to eq 2 }
          it { expect(result_names).to include "my-repo" }
          it { expect(result_names).to include "new-repo" }
        end

      end # repositories

      context "repositories with query" do

        context "query = repo" do

          let(:result) { registry_client.repositories.search("repo") }

          context "check" do
            let(:result_names) { result.map {|repo| repo["name"] } }
            it { expect(result.length).to eq 2 }
            it { expect(result_names).to include "my-repo" }
            it { expect(result_names).to include "new-repo" }
          end # check

        end # query = repo

        context "query = new" do

          let(:result) { registry_client.repositories.search("new") }

          context "check" do
            let(:result_names) { result.map {|repo| repo["name"] } }
            it { expect(result.length).to eq 1 }
            it { expect(result_names).to_not include "my-repo" }
            it { expect(result_names).to include "new-repo" }
          end

        end

      end # repositories with query

    end # create registry_client

  end # RegistryClient

end # SocialSnippet
