require "spec_helper"

module SocialSnippet::Repository

  describe RepositoryManager do

    let(:rest_resource) { ::RestClient::Resource.new "http://api.server/api/dummy" }

    before do
      allow_any_instance_of(::SocialSnippet::Registry::RegistryResources::Base).to receive(:rest_client) do
        rest_resource
      end
    end # use dummy api server

    before do # prepare repo_a
      repo = ::SocialSnippet::Repository::Models::Repository.create(
        :name => "repo_a",
        :url => "dummy://driver.test/user/repo_a",
      )
      repo.add_ref "master", "rev-master"
      repo.add_ref "develop", "rev-develop"
      repo.add_ref "1.2.3", "rev-1.2.3"
      repo.update_attributes! :current_ref => "master"

      # prepare package
      repo.add_package "1.2.3"
      package = ::SocialSnippet::Repository::Models::Package.create(
        :repo_name => "repo_a",
        :rev_hash => "rev-1.2.3",
      )
      package.add_file "snippet.json", {
        :name => "repo_a",
        :main => "src",
        :desc => "this is repo_a",
      }.to_json
    end

    describe "#resolve_snippet_path" do

      context "without repo" do

        context "cur = path/to/file.cpp" do

          let(:context) { ::SocialSnippet::Context.new("path/to/file.cpp") }

          context "@snip<./file2.cpp>" do

            let(:tag) { ::SocialSnippet::Tag.new("// @snip<./file2.cpp>") }

            context "result" do
              subject { fake_core.repo_manager.resolve_snippet_path(context, tag) }
              it { should eq "path/to/file2.cpp" }
            end

          end # snip<./file2.cpp>

          context "@snip <./subdir/file3.cpp>" do

            let(:tag) { ::SocialSnippet::Tag.new("// @snip <./subdir/file3.cpp>") }
            before { context.move tag.path }

            context "result" do
              subject { fake_core.repo_manager.resolve_snippet_path(context, tag) }
              it { should eq "path/to/subdir/file3.cpp" }
            end

          end # snip <./subdir/file3.cpp>

        end # cur = path/to/file.cpp

      end # without repo

      context "with repo" do

        context "cur = path/to/file.cpp" do

          let(:context) { ::SocialSnippet::Context.new("path/to/file.cpp") }

          context "@snip<repo_a:path/to/file2.cpp>" do

            let(:tag) { ::SocialSnippet::Tag.new("// @snip<repo_a:path/to/file2.cpp>") }

            context "result" do
              subject { fake_core.repo_manager.resolve_snippet_path(context, tag) }
              it { should eq ::File.join(fake_core.config.home, "packages", "repo_a", "rev-1.2.3", "src", "path", "to", "file2.cpp") }
            end

          end # snip<./file2.cpp>

        end # cur = path/to/file.cpp

      end # with repo

    end # resolve_snippet_path

    describe "#find_package" do

      context "find_package nil" do

        subject do
          lambda { fake_core.repo_manager.find_package nil }
        end
        it { should raise_error }

      end

      context "find_package empty_str" do
        subject do
          lambda { fake_core.repo_manager.find_package "" }
        end
        it { should raise_error }
      end

      context "create repo_a as a git repo" do

        context "find repo_a" do
          let(:repo) { fake_core.repo_manager.find_package("repo_a") }
          it { expect(repo.snippet_json["name"]).to eq "repo_a" }
          it { expect(repo.snippet_json["desc"]).to eq "this is repo_a" }
        end # find repo_a

      end # create three repos

    end # find_package

    describe "find_repositories_start_with" do

      context "prepare repositories" do

        before do
          ::SocialSnippet::Repository::Models::Repository.create :name => "my-repo"
          ::SocialSnippet::Repository::Models::Repository.create :name => "my-graph-lib"
          ::SocialSnippet::Repository::Models::Repository.create :name => "my-math-lib"
        end

        context "find my-" do
          subject { fake_core.repo_manager.find_repositories_start_with("my-") }
          it { should     include "my-repo" }
          it { should_not include "new-repo" }
          it { should     include "my-graph-lib" }
          it { should     include "my-math-lib" }
        end

        context "find my-re" do
          subject { fake_core.repo_manager.find_repositories_start_with("my-re") }
          it { should     include "my-repo" }
          it { should_not include "new-repo" }
          it { should_not include "my-graph-lib" }
          it { should_not include "my-math-lib" }
        end

        context "find new-" do
          subject { fake_core.repo_manager.find_repositories_start_with("new-") }
          it { should_not     include "new-repo" }
          it { should_not include "my-repo" }
          it { should_not include "my-graph-lib" }
          it { should_not include "my-math-lib" }
        end

      end

    end # find_repositories_start_with

  end # RepositoryManager

end # SocialSnippet::Repository
