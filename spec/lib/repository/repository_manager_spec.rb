require "spec_helper"

module SocialSnippet::Repository

  describe RepositoryManager, :repository_manager_current => true do

    before { stub_const "ENV", "SOCIAL_SNIPPET_HOME" => "/path/to" }

    let(:rest_resource) { ::RestClient::Resource.new "http://api.server/api/dummy" }

    before do
      allow_any_instance_of(::SocialSnippet::Registry::RegistryResources::Base).to receive(:rest_client) do
        rest_resource
      end
    end # use dummy api server

    let(:logger) do
      logger = ::SocialSnippet::Logger.new(STDOUT)
      logger.level = ::SocialSnippet::Logger::Severity::UNKNOWN
      logger
    end

    let(:config) do
      ::SocialSnippet::Config.new(social_snippet)
    end

    let(:social_snippet) do
      class Fake; end
      Fake.new
    end

    before do
      allow(social_snippet).to receive(:logger).and_return logger
      allow(social_snippet).to receive(:config).and_return config
    end

    let(:repo_manager) { RepositoryManager.new social_snippet }
    let(:commit_id) { "dummycommitid" }
    let(:short_commit_id) { commit_id[0..7] }

    describe "#resolve_snippet_path" do

      context "without repo" do

        context "cur = path/to/file.cpp" do

          let(:context) { ::SocialSnippet::Context.new("path/to/file.cpp") }

          context "@snip<./file2.cpp>" do

            let(:tag) { ::SocialSnippet::Tag.new("// @snip<./file2.cpp>") }

            context "result" do
              subject { repo_manager.resolve_snippet_path(context, tag) }
              it { should eq "path/to/file2.cpp" }
            end

          end # snip<./file2.cpp>

          context "@snip <./subdir/file3.cpp>" do

            let(:tag) { ::SocialSnippet::Tag.new("// @snip <./subdir/file3.cpp>") }

            context "result" do
              subject { repo_manager.resolve_snippet_path(context, tag) }
              it { should eq "path/to/subdir/file3.cpp" }
            end

          end # snip <./subdir/file3.cpp>

        end # cur = path/to/file.cpp

      end # without repo

      context "with repo" do

        let(:repo_path) { "#{ENV["SOCIAL_SNIPPET_HOME"]}/repo" }

        before do
          FileUtils.mkdir_p "#{repo_path}/repo_a"
          FileUtils.mkdir_p "#{repo_path}/repo_a/.git"
          FileUtils.touch   "#{repo_path}/repo_a/snippet.json"

          File.write "#{repo_path}/repo_a/snippet.json", [
            '{',
            '  "name": "repo_a",',
            '  "desc": "this is repo_a",',
            '  "language": "C++",',
            '  "main": "src"',
            '}',
          ].join($/)

          allow(repo_manager).to receive(:find_repository).with("repo_a") do |path|
            repo = ::SocialSnippet::Repository::Drivers::BaseRepository.new("#{repo_path}/repo_a")
            expect(repo).to receive(:commit_id).and_return commit_id
            repo.load_snippet_json
            repo.create_cache repo_manager.repo_cache_path
            repo
          end
        end

        context "cur = path/to/file.cpp" do

          let(:context) { ::SocialSnippet::Context.new("path/to/file.cpp") }

          context "@snip<repo_a:path/to/file2.cpp>" do

            let(:tag) { ::SocialSnippet::Tag.new("// @snip<repo_a:path/to/file2.cpp>") }

            context "result" do
              subject { repo_manager.resolve_snippet_path(context, tag) }
              it { should eq "/path/to/repo_cache/repo_a/#{commit_id[0..7]}/src/path/to/file2.cpp" }
            end

          end # snip<./file2.cpp>

        end # cur = path/to/file.cpp

      end # with repo

    end # resolve_snippet_path

    describe "#find_repository" do

      let(:repo_path) { "#{ENV["SOCIAL_SNIPPET_HOME"]}/repo" }

      context "passed empty name" do

        it { expect(repo_manager.find_repository(nil)).to be_nil }
        it { expect(repo_manager.find_repository("")).to be_nil }

      end

      context "create repo_a as a git repo" do

        before do
          FileUtils.mkdir_p "#{repo_path}/repo_a"
          FileUtils.mkdir_p "#{repo_path}/repo_a/.git"
          FileUtils.touch   "#{repo_path}/repo_a/snippet.json"

          File.write "#{repo_path}/repo_a/snippet.json", [
            '{',
            '  "name": "repo_a",',
            '  "desc": "this is repo_a",',
            '  "language": "C++"',
            '}',
          ].join($/)
        end

        before do
          expect(::SocialSnippet::Repository::Drivers::GitRepository).to receive(:new) do |path|
            ::SocialSnippet::Repository::Drivers::BaseRepository.new(path)
          end
          expect_any_instance_of(::SocialSnippet::Repository::Drivers::BaseRepository).to receive(:commit_id).and_return commit_id
        end

        context "find repo_a" do
          let(:repo) { repo_manager.find_repository("repo_a") }
          it { expect(repo.name).to eq "repo_a" }
          it { expect(repo.desc).to eq "this is repo_a" }
        end # find repo_a

      end # create three repos

    end # find_repository

    describe "find_repositories_start_with" do

      let(:dummy_install_path) { "/path/to/install/path" }

      before do
        FileUtils.mkdir_p "#{dummy_install_path}"
        FileUtils.mkdir_p "#{dummy_install_path}/my-repo"
        FileUtils.mkdir_p "#{dummy_install_path}/new-repo"
        FileUtils.mkdir_p "#{dummy_install_path}/my-graph-lib"
        FileUtils.mkdir_p "#{dummy_install_path}/my-math-lib"
        allow(repo_manager.installer).to receive(:path).and_return dummy_install_path
      end # prepare install_path

      context "find my-" do
        subject { repo_manager.find_repositories_start_with("my-") }
        it { should     include "my-repo" }
        it { should_not include "new-repo" }
        it { should     include "my-graph-lib" }
        it { should     include "my-math-lib" }
      end

      context "find my-re" do
        subject { repo_manager.find_repositories_start_with("my-re") }
        it { should     include "my-repo" }
        it { should_not include "new-repo" }
        it { should_not include "my-graph-lib" }
        it { should_not include "my-math-lib" }
      end

      context "find new-" do
        subject { repo_manager.find_repositories_start_with("new-") }
        it { should     include "new-repo" }
        it { should_not include "my-repo" }
        it { should_not include "my-graph-lib" }
        it { should_not include "my-math-lib" }
      end

    end # find_repositories_start_with

  end # RepositoryManager

end # SocialSnippet::Repository
