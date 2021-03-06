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
        pkg.add_file "snippet.json", {
          :name => name,
        }.to_json
        pkg
      end
      allow(fake_core.repo_manager).to receive(:get_snippet) do |c, t|
        ::SocialSnippet::Snippet.new_text(fake_core, t.repo)
      end
    end

    before do
      # prepare snippet.css (global)
      fake_core.storage.write fake_core.config.snippet_css, [
        "snippet {",
        "  margin-top: 0;",
        "  margin-bottom: 0;",
        "}",
      ].join($/)
    end

    describe "@begin_cut / @end_cut" do

      describe "ruby's require()" do

        before do
          allow(fake_core.repo_manager).to receive(:get_snippet) do |c, t|
            ::SocialSnippet::Snippet.new_text(fake_core, [
              "def foo",
              "  42",
              "end",
            ].join($/))
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

      describe "snippet.css", :current => true do

        context "snippet { margin-bottom: 3 }" do

          before do
            fake_core.storage.write "snippet.css", [
              "snippet { margin-bottom: 3; }"
            ].join($/)
          end

          let(:resolver) do
            ::SocialSnippet::Resolvers::InsertResolver.new(fake_core, ::Hash.new)
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

        end # snippet { margin-bottom: 3 }

        context "snippet { margin-top: 3; margin-bottom: 3 }" do

          before do
            fake_core.storage.write "snippet.css", [
              "snippet {",
              "  margin-top: 3;",
              "  margin-bottom: 3;",
              "}",
            ].join($/)
          end

          let(:resolver) do
            ::SocialSnippet::Resolvers::InsertResolver.new(fake_core, ::Hash.new)
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
              "",
              "",
              "",
              "// @snippet <my-repo-2:path/to/file.d>",
              "my-repo-2",
              "",
              "",
              "",
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

        end # snippet { margin-top: 3; margin-bottom: 3 }

        context "global - snippet { margin-bottom: 3 }" do

          before do
            fake_core.storage.write fake_core.config.snippet_css, [
              "snippet{ margin-top: 3; margin-bottom: 0 }"
            ].join($/)
          end

          let(:resolver) do
            ::SocialSnippet::Resolvers::InsertResolver.new(fake_core, ::Hash.new)
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

        end

        context "local css > global css" do

          before do
            fake_core.storage.write fake_core.config.snippet_css, [
              "snippet{ margin-top: 0; margin-bottom: 0 }"
            ].join($/)

            fake_core.storage.write "snippet.css", [
              "snippet{ margin-top: 3; margin-bottom: 0 }"
            ].join($/)
          end

          let(:resolver) do
            ::SocialSnippet::Resolvers::InsertResolver.new(fake_core, ::Hash.new)
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

        end # local css > global css

        context "multi-selector case" do

          before do
            fake_core.storage.write fake_core.config.snippet_css, [
              "abcde, snippet, .test, #testtest { margin-top: 2; margin-bottom: 0 }"
            ].join($/)
          end

          let(:resolver) do
            ::SocialSnippet::Resolvers::InsertResolver.new(fake_core, ::Hash.new)
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
              "// @snippet <my-repo-1:path/to/file.d>",
              "my-repo-1",
              "",
              "",
              "// @snippet <my-repo-2:path/to/file.d>",
              "my-repo-2",
              "",
              "",
              "// @snippet <my-repo-3:path/to/file.d>",
              "my-repo-3",
            ].join($/)
          end

          subject { resolver.insert input }
          it { should eq expected }

        end # multi-selectors case

      end # snippet.css

    end # test styling

  end # prepare stubs

end # SocialSnippet::Resolvers::InsertResolver

