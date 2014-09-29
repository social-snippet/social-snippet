require "spec_helper"

module SocialSnippet

  describe SocialSnippet::SocialSnippet do

    # Enable FakeFS
    before { FakeFS.activate! }
    after { FakeFS.deactivate! }

    let(:instance) { SocialSnippet.new }
    let(:repo_manager) { RepositoryManager.new(Config.new) }
    let(:commit_id) { "dummycommitid" }
    let(:short_commit_id) { commit_id[0..7] }
    let(:repo_path) { "#{ENV["HOME"]}/.social-snippet/repo" }
    let(:repo_cache_path) { "#{ENV["HOME"]}/.social-snippet/repo_cache" }

    before { allow(instance).to receive(:repo_manager).and_return repo_manager }

    describe "#insert_snippet" do

      context "create files" do

        before do
          repo_name = "my-repo"

          FileUtils.mkdir_p "#{repo_path}"
          FileUtils.mkdir_p "#{repo_path}/my-repo"
          FileUtils.mkdir_p "#{repo_path}/my-repo/.git"
          FileUtils.mkdir_p "#{repo_path}/my-repo/src"
          FileUtils.touch   "#{repo_path}/my-repo/snippet.json"
          FileUtils.touch   "#{repo_path}/my-repo/src/get_42.cpp"

          # snippet.json
          File.write "#{repo_path}/my-repo/snippet.json", [
            '{',
            '  "name": "my-repo",',
            '  "language": "C++",',
            '  "main": "src/"',
            '}',
          ].join("\n")

          # src/get_42.cpp
          File.write "#{repo_path}/my-repo/src/get_42.cpp", [
            'int get_42() {',
            '  return 42;',
            '}',
          ].join("\n")

          repo_config = Proc.new do |path|
            repo = Repository::BaseRepository.new("#{repo_path}/my-repo")
            allow(repo).to receive(:get_commit_id).and_return commit_id
            allow(repo).to receive(:get_refs).and_return []
            repo.load_snippet_json
            repo.create_cache repo_cache_path
            repo
          end

          allow(repo_manager).to receive(:find_repository).with("my-repo") { repo_config.call }
          allow(repo_manager).to receive(:find_repository).with("my-repo", short_commit_id) { repo_config.call }
        end # prepare for my-repo

        context "there are no @snip tags" do

          let(:input) do
            [
              '#include <iostream>',
              '',
              'int main() {',
              '  std::cout << get_42() << std::endl;',
              '  return 0;',
              '}',
            ].join("\n")
          end

          let(:output) do
            [
              '#include <iostream>',
              '',
              'int main() {',
              '  std::cout << get_42() << std::endl;',
              '  return 0;',
              '}',
            ].join("\n")
          end

          subject { instance.insert_snippet(input) }
          it { should eq output }

        end # there is no @snip tags

        context "there is a @snip tag" do

          let(:input) do
            [
              '#include <iostream>',
              '',
              '// @snip <my-repo:get_42.cpp>',
              '',
              'int main() {',
              '  std::cout << get_42() << std::endl;',
              '  return 0;',
              '}',
            ].join("\n")
          end

          let(:output) do
            [
              '#include <iostream>',
              '',
              '// @snippet <my-repo#dummycom:get_42.cpp>',
              'int get_42() {',
              '  return 42;',
              '}',
              '',
              'int main() {',
              '  std::cout << get_42() << std::endl;',
              '  return 0;',
              '}',
            ].join("\n")
          end

          subject { instance.insert_snippet(input) }
          it { should eq output }

        end # there is a @snip tag

      end # create file

    end # insert_snippet

  end # SocialSnippet::SocialSnippet


end # SocialSnippet
