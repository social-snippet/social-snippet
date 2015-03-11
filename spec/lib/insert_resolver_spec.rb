require "spec_helper"

describe SocialSnippet::Resolvers::InsertResolver do

  context "prepare stubs" do

    before do
      allow(fake_core.repo_manager).to receive(:find_repository) do |name|
        repo = ::SocialSnippet::Repository::Models::Repository.new(
          :repo_name => name,
        )
        repo
      end
      allow(fake_core.repo_manager).to receive(:find_package) do |name|
        pkg = ::SocialSnippet::Repository::Models::Package.new(
          :repo_name => name,
          :rev_hash => "rev-#{name}",
        )
        pkg.add_system_file "snippet.json", {
          :name => name,
        }.to_json
        pkg
      end
      allow(fake_core.repo_manager).to receive(:get_snippet) do |c, t|
        ::SocialSnippet::Snippet.new_text(t.repo)
      end
    end

    describe "@begin_cut / @end_cut" do

      describe "ruby's require()" do

        before do
          allow(fake_core.repo_manager).to receive(:get_snippet) do |c, t|
            ::SocialSnippet::Snippet.new_text([
              "def foo",
              "  42",
              "end",
            ].join $/)
          end
        end # prepare snippet

        let(:resolver) do
          ::SocialSnippet::Resolvers::InsertResolver.new(fake_core)
        end

        let(:input) do
          [
            "# @begin_cut",
            "require './foo'",
            "# @end_cut",
            "# @snip <./foo.rb>",
            "",
            "def bar",
            "  foo",
            "end",
          ].join($/)
        end

        let(:expected) do
          [
            "# @snippet <foo.rb>",
            "def foo",
            "  42",
            "end",
            "",
            "def bar",
            "  foo",
            "end",
          ].join($/)
        end

        subject { resolver.insert input }
        it { should eq expected }

      end

    end # begin_cut / end_cut

    describe "styling" do

      context "no options" do

        let(:resolver) do
          ::SocialSnippet::Resolvers::InsertResolver.new(fake_core)
        end

        let(:input) do
          [
            "// @snip <my-repo-1:path/to/file.d>",
            "// @snip <my-repo-2:path/to/file.d>",
            "// @snip <my-repo-3:path/to/file.d>",
          ].join($/)
        end

        let(:expected) do
          [
            "// @snippet <my-repo-1:path/to/file.d>",
            "my-repo-1",
            "// @snippet <my-repo-2:path/to/file.d>",
            "my-repo-2",
            "// @snippet <my-repo-3:path/to/file.d>",
            "my-repo-3",
          ].join($/)
        end

        subject { resolver.insert input }
        it { should eq expected }

      end # no options

      context ":margin_top => 3" do

        let(:resolver) do
          ::SocialSnippet::Resolvers::InsertResolver.new(fake_core, {
            :margin_top => 3,
          })
        end

        let(:input) do
          [
            "// @snip <my-repo-1:path/to/file.d>",
            "// @snip <my-repo-2:path/to/file.d>",
            "// @snip <my-repo-3:path/to/file.d>",
          ].join($/)
        end

        let(:expected) do
          [
            "",
            "",
            "",
            "// @snippet <my-repo-1:path/to/file.d>",
            "my-repo-1",
            "",
            "",
            "",
            "// @snippet <my-repo-2:path/to/file.d>",
            "my-repo-2",
            "",
            "",
            "",
            "// @snippet <my-repo-3:path/to/file.d>",
            "my-repo-3",
          ].join($/)
        end

        subject { resolver.insert input }
        it { should eq expected }

      end # :margin_top

      context ":margin_bottom => 3" do

        let(:resolver) do
          ::SocialSnippet::Resolvers::InsertResolver.new(fake_core, {
            :margin_bottom => 3,
          })
        end

        let(:input) do
          [
            "// @snip <my-repo-1:path/to/file.d>",
            "// @snip <my-repo-2:path/to/file.d>",
            "// @snip <my-repo-3:path/to/file.d>",
          ].join($/)
        end

        let(:expected) do
          [
            "// @snippet <my-repo-1:path/to/file.d>",
            "my-repo-1",
            "",
            "",
            "",
            "// @snippet <my-repo-2:path/to/file.d>",
            "my-repo-2",
            "",
            "",
            "",
            "// @snippet <my-repo-3:path/to/file.d>",
            "my-repo-3",
            "",
            "",
            "",
          ].join($/)
        end

        subject { resolver.insert input }
        it { should eq expected }

      end # :margin_bottom

    end # test styling

  end # prepare stubs

end # SocialSnippet::Resolvers::InsertResolver

