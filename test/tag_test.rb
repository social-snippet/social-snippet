require "spec_helper"

module SocialSnippet

  describe Tag do

    describe "#is_tag_line()" do

      context "@snip" do

        context "valid cases" do

          context "relative path without `./`" do
            it { expect(Tag.is_tag_line("// @snip <path/to/file.cpp>")).to be_truthy }
            it { expect(Tag.is_tag_line("/* @snip <path/to/file.c> */")).to be_truthy }
            it { expect(Tag.is_tag_line("# @snip <path/to/file.py>")).to be_truthy }
          end

          context "relative path start with `./`" do
            it { expect(Tag.is_tag_line("// @snip <./path/to/file.cpp>")).to be_truthy }
            it { expect(Tag.is_tag_line("/* @snip <./path/to/file.c> */")).to be_truthy }
            it { expect(Tag.is_tag_line("# @snip <./path/to/file.py>")).to be_truthy }
          end

          context "with repo without `/`" do
            it { expect(Tag.is_tag_line("// @snip <repo:path/to/file.cpp>")).to be_truthy }
            it { expect(Tag.is_tag_line("/* @snip <repo:path/to/file.c> */")).to be_truthy }
            it { expect(Tag.is_tag_line("# @snip <repo:path/to/file.py>")).to be_truthy }
          end

          context "with repo and start with `/`" do
            it { expect(Tag.is_tag_line("// @snip <repo:/path/to/file.cpp>")).to be_truthy }
            it { expect(Tag.is_tag_line("/* @snip <repo:/path/to/file.c> */")).to be_truthy }
            it { expect(Tag.is_tag_line("# @snip <repo:/path/to/file.py>")).to be_truthy }
          end

          # TODO: add `@snip <{repo}#{version}:{path}>`

        end

        context "invalid cases" do
          it { expect(Tag.is_tag_line("// @snip2 <path/to/file.cpp>")).to be_falsey }
          it { expect(Tag.is_tag_line("// @sni <path/to/file.cpp>")).to be_falsey }
          it { expect(Tag.is_tag_line("// @snip <path/to/file.cpp")).to be_falsey }
          it { expect(Tag.is_tag_line("// @snip path/to/file.cpp>")).to be_falsey }
          it { expect(Tag.is_tag_line("/* @ snip <path/to/file.c> */")).to be_falsey }
          it { expect(Tag.is_tag_line("# @snp <path/to/file.py>")).to be_falsey }
        end # invalid cases

      end # @snip

      context "@snippet" do

        context "valid cases" do

          context "relative path without `./`" do
            it { expect(Tag.is_tag_line("// @snippet <path/to/file.cpp>")).to be_truthy }
            it { expect(Tag.is_tag_line("/* @snippet <path/to/file.c> */")).to be_truthy }
            it { expect(Tag.is_tag_line("# @snippet <path/to/file.py>")).to be_truthy }
          end

          context "relative path start with `./`" do
            it { expect(Tag.is_tag_line("// @snippet <./path/to/file.cpp>")).to be_truthy }
            it { expect(Tag.is_tag_line("/* @snippet <./path/to/file.c> */")).to be_truthy }
            it { expect(Tag.is_tag_line("# @snippet <./path/to/file.py>")).to be_truthy }
          end

          context "with repo" do
            it { expect(Tag.is_tag_line("// @snippet <repo:path/to/file.cpp>")).to be_truthy }
            it { expect(Tag.is_tag_line("/* @snippet <repo:path/to/file.c> */")).to be_truthy }
            it { expect(Tag.is_tag_line("# @snippet <repo:path/to/file.py>")).to be_truthy }
          end

          context "with repo start with `/`" do
            it { expect(Tag.is_tag_line("// @snippet <repo:/path/to/file.cpp>")).to be_truthy }
            it { expect(Tag.is_tag_line("/* @snippet <repo:/path/to/file.c> */")).to be_truthy }
            it { expect(Tag.is_tag_line("# @snippet <repo:/path/to/file.py>")).to be_truthy }
          end

          # TODO: add `@snippet <{repo}#{version}:{path}>`

        end # valid cases

        context "invalid cases" do
          it { expect(Tag.is_tag_line("// @snippet2 <path/to/file.cpp>")).to be_falsey }
          it { expect(Tag.is_tag_line("// @snippe <path/to/file.cpp>")).to be_falsey }
          it { expect(Tag.is_tag_line("// @snippet <path/to/file.cpp")).to be_falsey }
          it { expect(Tag.is_tag_line("// @snippet path/to/file.cpp>")).to be_falsey }
          it { expect(Tag.is_tag_line("/* @ snippet <path/to/file.c> */")).to be_falsey }
          it { expect(Tag.is_tag_line("# @snppet <path/to/file.py>")).to be_falsey }
        end

      end # @snippet

    end # is_tag_line

  end # Tag

end # SocialSnippet
