require "spec_helper"

module SocialSnippet

  describe SocialSnippet::SocialSnippet do

    # Enable FakeFS
    before { FakeFS.activate! }
    after { FakeFS.deactivate! }

    let(:instance) { SocialSnippet.new }


    describe "#resolve_snippet_path" do

      context "without repo" do

        context "cur = path/to/file.cpp" do

          let(:context) { Context.new("path/to/file.cpp") }

          context "@snip<./file2.cpp>" do

            let(:tag) { Tag.new("// @snip<./file2.cpp>") }

            context "result" do
              subject { instance.resolve_snippet_path(context, tag) }
              it { should eq "path/to/file2.cpp" }
            end

          end # snip<./file2.cpp>

          context "@snip <./subdir/file3.cpp>" do

            let(:tag) { Tag.new("// @snip <./subdir/file3.cpp>") }

            context "result" do
              subject { instance.resolve_snippet_path(context, tag) }
              it { should eq "path/to/subdir/file3.cpp" }
            end

          end # snip <./subdir/file3.cpp>

        end # cur = path/to/file.cpp

      end # without repo

      context "with repo" do

        before { ENV["SOCIAL_SNIPPET_HOME"] = "/path/to" }
        after { ENV.delete "SOCIAL_SNIPPET_HOME" }

        let(:repo_path) { "#{ENV["SOCIAL_SNIPPET_HOME"]}/repo" }

        before do
          # create files
          FileUtils.mkdir_p "#{repo_path}/repo_a"
          FileUtils.mkdir_p "#{repo_path}/repo_a/.git"
          FileUtils.touch "#{repo_path}/repo_a/snippet.json"
          File.write "#{repo_path}/repo_a/snippet.json", [
            '{',
            '  "name": "repo_a",',
            '  "desc": "this is repo_a",',
            '  "language": "C++",',
            '  "main": "src"',
            '}',
          ].join("\n")
        end

        let(:commit_id) { "dummyyyyyyy" }

        before do
          # do dummy checkout
          expect_any_instance_of(Repository::GitRepository).to receive(:checkout).and_return true

          # return dummy commit id
          expect_any_instance_of(Repository::GitRepository).to receive(:get_commit_id).and_return commit_id
        end

        context "cur = path/to/file.cpp" do

          let(:context) { Context.new("path/to/file.cpp") }

          context "@snip<repo_a:path/to/file2.cpp>" do

            let(:tag) { Tag.new("// @snip<repo_a:path/to/file2.cpp>") }

            context "result" do
              subject { instance.resolve_snippet_path(context, tag) }
              it { should eq "/path/to/repo_cache/repo_a/#{commit_id[0..7]}/src/path/to/file2.cpp" }
            end

          end # snip<./file2.cpp>

        end # cur = path/to/file.cpp

      end # with repo

    end # resolve_snippet_path


    describe "#find_repository" do

      let(:repo_path) { "#{ENV["HOME"]}/.social-snippet/repo" }

      context "create repo_a as a git repo" do

        before do
          # create files
          FileUtils.mkdir_p "#{repo_path}/repo_a"
          FileUtils.mkdir_p "#{repo_path}/repo_a/.git"
          FileUtils.touch "#{repo_path}/repo_a/snippet.json"
          File.write "#{repo_path}/repo_a/snippet.json", [
            '{',
            '  "name": "repo_a",',
            '  "desc": "this is repo_a",',
            '  "language": "C++"',
            '}',
          ].join("\n")
        end

        before do
          # do dummy checkout
          expect_any_instance_of(Repository::GitRepository).to receive(:checkout).and_return true

          # return dummy commit id
          expect_any_instance_of(Repository::GitRepository).to receive(:get_commit_id).and_return "dummy_commit_id"
        end

        context "find repo_a" do

          let(:repo) { instance.find_repository("repo_a") }

          context "name" do
            subject { repo.name }
            it { should eq "repo_a" }
          end

          context "desc" do
            subject { repo.desc }
            it { should eq "this is repo_a" }
          end

        end # find repo_a

      end # create three repos

    end # find_repository

  end # SocialSnippet::SocialSnippet


end # SocialSnippet
