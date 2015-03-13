require "spec_helper"

module SocialSnippet

  describe Core do

    let(:commit_id) { "dummycommitid" }
    let(:short_commit_id) { commit_id[0..7] }
    let(:repo_path) { "#{ENV["HOME"]}/.social-snippet/repo" }
    let(:repo_cache_path) { "#{ENV["HOME"]}/.social-snippet/repo_cache" }

    describe "#insert_snippet" do

      context "prepare repository" do

        before do
          repo = ::SocialSnippet::Repository::Models::Repository.create(
            :name => "my-repo",
            :current_ref => "master",
          )
          repo.add_ref "master", "rev-master"
          package = ::SocialSnippet::Repository::Models::Package.create(
            :repo_name => "my-repo",
            :rev_hash => "rev-master",
          )
          package.add_file "snippet.json", {
            :name => "my-repo",
            :main => "src",
          }.to_json
          package.add_directory "src"
          package.add_file "src/get_42.cpp", [
            "int get_42() {",
            "  return 42;",
            "}",
          ].join($/)
        end

        context "there are no @snip tags" do

          let(:input) do
            [
              '#include <iostream>',
              '',
              'int main() {',
              '  std::cout << get_42() << std::endl;',
              '  return 0;',
              '}',
            ].join($/)
          end

          let(:output) do
            [
              '#include <iostream>',
              '',
              'int main() {',
              '  std::cout << get_42() << std::endl;',
              '  return 0;',
              '}',
            ].join($/)
          end

          subject { fake_core.api.insert_snippet(input) }
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
            ].join($/)
          end

          let(:output) do
            [
              '#include <iostream>',
              '',
              '// @snippet <my-repo#master:get_42.cpp>',
              'int get_42() {',
              '  return 42;',
              '}',
              '',
              'int main() {',
              '  std::cout << get_42() << std::endl;',
              '  return 0;',
              '}',
            ].join($/)
          end

          subject { fake_core.api.insert_snippet(input) }
          it { should eq output }

        end # there is a @snip tag

      end # create file

    end # insert_snippet

  end # SocialSnippet::Core

end # SocialSnippet
