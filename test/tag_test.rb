require "spec_helper"

module SocialSnippet

  describe Tag do

    describe "#get_spaces" do

      context "valid cases" do
        it { expect(Tag.get_spaces("// @snip <path/to/file.cpp>")).to eq " " }
        it { expect(Tag.get_spaces("# @snip <path/to/file.rb>")).to eq " " }
        it { expect(Tag.get_spaces("/* @snip <path/to/file.c> */")).to eq " " }
        it { expect(Tag.get_spaces("@snip <path/to/file.c>")).to eq " " }

        it { expect(Tag.get_spaces("// @snip<path/to/file.cpp>test1")).to eq "" }
        it { expect(Tag.get_spaces("# @snip<path/to/file.rb>test2")).to eq "" }
        it { expect(Tag.get_spaces("/* @snip<path/to/file.c>test3*/")).to eq "" }
        it { expect(Tag.get_spaces("@snip<path/to/file.c>test4")).to eq "" }
      end # valid caess

      context "invalid cases" do
        it { expect(Tag.get_spaces("// @snip <path/to/file.cpp")).to eq "" }
        it { expect(Tag.get_spaces("# @snp <path/to/file.rb>")).to eq "" }
        it { expect(Tag.get_spaces("/* @snip path/to/file.c> */")).to eq "" }
      end # invalid cases

    end # get_spaces

    describe "#get_suffix" do

      context "valid cases" do
        it { expect(Tag.get_suffix("// @snip <path/to/file.cpp>")).to eq "" }
        it { expect(Tag.get_suffix("# @snip <path/to/file.rb>")).to eq "" }
        it { expect(Tag.get_suffix("/* @snip <path/to/file.c> */")).to eq " */" }
        it { expect(Tag.get_suffix("@snip <path/to/file.c>")).to eq "" }

        it { expect(Tag.get_suffix("// @snip <path/to/file.cpp>test1")).to eq "test1" }
        it { expect(Tag.get_suffix("# @snip <path/to/file.rb>test2")).to eq "test2" }
        it { expect(Tag.get_suffix("/* @snip <path/to/file.c>test3*/")).to eq "test3*/" }
        it { expect(Tag.get_suffix("@snip <path/to/file.c>test4")).to eq "test4" }
      end # valid caess

      context "invalid cases" do
        it { expect(Tag.get_suffix("// @snip <path/to/file.cpp")).to eq "" }
        it { expect(Tag.get_suffix("# @snp <path/to/file.rb>")).to eq "" }
        it { expect(Tag.get_suffix("/* @snip path/to/file.c> */")).to eq "" }
      end # invalid cases

    end # get_suffix

    describe "#get_prefix" do

      context "valid cases" do
        it { expect(Tag.get_prefix("// @snip <path/to/file.cpp>")).to eq "// " }
        it { expect(Tag.get_prefix("# @snip <path/to/file.rb>")).to eq "# " }
        it { expect(Tag.get_prefix("/* @snip <path/to/file.c> */")).to eq "/* " }
        it { expect(Tag.get_prefix("@snip <path/to/file.c>")).to eq "" }
      end # valid caess

      context "invalid cases" do
        it { expect(Tag.get_prefix("// @snip <path/to/file.cpp")).to eq "" }
        it { expect(Tag.get_prefix("# @snp <path/to/file.rb>")).to eq "" }
        it { expect(Tag.get_prefix("/* @snip path/to/file.c> */")).to eq "" }
      end # invalid cases

    end # get_prefix

    describe "#get_path" do

      context "valid cases" do

        context "without repo" do
          it { expect(Tag.get_path("// @snip <path/to/file.cpp>")).to eq "path/to/file.cpp" }
          it { expect(Tag.get_path("# @snip <path/to/file.rb>")).to eq "path/to/file.rb" }
          it { expect(Tag.get_path("/* @snip <path/to/file.c> */")).to eq "path/to/file.c" }
        end # without repo

        context "with repo" do
          it { expect(Tag.get_path("// @snip <repo:path/to/file.cpp>")).to eq "path/to/file.cpp" }
          it { expect(Tag.get_path("# @snip <repo:path/to/file.rb>")).to eq "path/to/file.rb" }
          it { expect(Tag.get_path("/* @snip <repo:path/to/file.rb> */")).to eq "path/to/file.rb" }
          it { expect(Tag.get_path("// @snip <my-repo:path/to/file.cpp>")).to eq "path/to/file.cpp" }
          it { expect(Tag.get_path("# @snip <my-repo:path/to/file.rb>")).to eq "path/to/file.rb" }
          it { expect(Tag.get_path("/* @snip <my-repo:path/to/file.c> */")).to eq "path/to/file.c" }
        end # with repo

      end # valid cases

      context "invalid cases" do

        context "without repo" do
          it { expect(Tag.get_path("// snip <path/to/file.cpp>")).to eq "" }
          it { expect(Tag.get_path("# @sni <path/to/file.rb>")).to eq "" }
          it { expect(Tag.get_path("/* @snipp <path/to/file.c> */")).to eq "" }
        end # without repo

        context "with repo" do
          it { expect(Tag.get_path("// @snip repo:path/to/file.cpp")).to eq "" }
          it { expect(Tag.get_path("# @snip <repo:path/to/file.rb")).to eq "" }
          it { expect(Tag.get_path("/* @snip repo:path/to/file.rb> */")).to eq "" }
          it { expect(Tag.get_path("//snip <my-repo:path/to/file.cpp>")).to eq "" }
          it { expect(Tag.get_path("# @snip2 <my-repo:path/to/file.rb>")).to eq "" }
          it { expect(Tag.get_path("/* @s <my-repo:path/to/file.c> */")).to eq "" }
        end # with repo

      end # valid cases

    end # get_path

    describe "#get_repo" do

      context "without repo" do
        it { expect(Tag.get_repo("// @snip <path/to/file.cpp>")).to eq "" }
        it { expect(Tag.get_repo("# @snip <path/to/file.rb>")).to eq "" }
        it { expect(Tag.get_repo("/* @snip <path/to/file.rb> */")).to eq "" }
      end # without repo

      context "with repo" do
        it { expect(Tag.get_repo("// @snip <repo:path/to/file.cpp>")).to eq "repo" }
        it { expect(Tag.get_repo("# @snip <repo:path/to/file.rb>")).to eq "repo" }
        it { expect(Tag.get_repo("/* @snip <repo:path/to/file.rb> */")).to eq "repo" }
        it { expect(Tag.get_repo("// @snip <my-repo:path/to/file.cpp>")).to eq "my-repo" }
        it { expect(Tag.get_repo("# @snip <my-repo:path/to/file.rb>")).to eq "my-repo" }
        it { expect(Tag.get_repo("/* @snip <my-repo:path/to/file.rb> */")).to eq "my-repo" }
      end # with repo

    end # get_repo

    describe "#is_snip_tag_line()" do

      context "valid cases" do

        context "relative path without `./`" do
          it { expect(Tag.is_snip_tag_line("// @snip <path/to/file.cpp>")).to be_truthy }
          it { expect(Tag.is_snip_tag_line("/* @snip <path/to/file.c> */")).to be_truthy }
          it { expect(Tag.is_snip_tag_line("# @snip <path/to/file.py>")).to be_truthy }
        end

        context "relative path start with `./`" do
          it { expect(Tag.is_snip_tag_line("// @snip <./path/to/file.cpp>")).to be_truthy }
          it { expect(Tag.is_snip_tag_line("/* @snip <./path/to/file.c> */")).to be_truthy }
          it { expect(Tag.is_snip_tag_line("# @snip <./path/to/file.py>")).to be_truthy }
        end

        context "with repo without `/`" do
          it { expect(Tag.is_snip_tag_line("// @snip <repo:path/to/file.cpp>")).to be_truthy }
          it { expect(Tag.is_snip_tag_line("/* @snip <repo:path/to/file.c> */")).to be_truthy }
          it { expect(Tag.is_snip_tag_line("# @snip <repo:path/to/file.py>")).to be_truthy }
        end

        context "with repo and start with `/`" do
          it { expect(Tag.is_snip_tag_line("// @snip <repo:/path/to/file.cpp>")).to be_truthy }
          it { expect(Tag.is_snip_tag_line("/* @snip <repo:/path/to/file.c> */")).to be_truthy }
          it { expect(Tag.is_snip_tag_line("# @snip <repo:/path/to/file.py>")).to be_truthy }
        end

        # TODO: add `@snip <{repo}#{version}:{path}>`

      end # valid cases

      context "invalid cases" do
        it { expect(Tag.is_snip_tag_line("// @snip2 <path/to/file.cpp>")).to be_falsey }
        it { expect(Tag.is_snip_tag_line("// @sni <path/to/file.cpp>")).to be_falsey }
        it { expect(Tag.is_snip_tag_line("// @snip <path/to/file.cpp")).to be_falsey }
        it { expect(Tag.is_snip_tag_line("// @snip path/to/file.cpp>")).to be_falsey }
        it { expect(Tag.is_snip_tag_line("/* @ snip <path/to/file.c> */")).to be_falsey }
        it { expect(Tag.is_snip_tag_line("# @snp <path/to/file.py>")).to be_falsey }
      end # invalid cases

    end # is_snip_tag_line

    describe "#is_snippet_tag_line()" do

      context "valid cases" do

        context "relative path without `./`" do
          it { expect(Tag.is_snippet_tag_line("// @snippet <path/to/file.cpp>")).to be_truthy }
          it { expect(Tag.is_snippet_tag_line("/* @snippet <path/to/file.c> */")).to be_truthy }
          it { expect(Tag.is_snippet_tag_line("# @snippet <path/to/file.py>")).to be_truthy }
        end

        context "relative path start with `./`" do
          it { expect(Tag.is_snippet_tag_line("// @snippet <./path/to/file.cpp>")).to be_truthy }
          it { expect(Tag.is_snippet_tag_line("/* @snippet <./path/to/file.c> */")).to be_truthy }
          it { expect(Tag.is_snippet_tag_line("# @snippet <./path/to/file.py>")).to be_truthy }
        end

        context "with repo" do
          it { expect(Tag.is_snippet_tag_line("// @snippet <repo:path/to/file.cpp>")).to be_truthy }
          it { expect(Tag.is_snippet_tag_line("/* @snippet <repo:path/to/file.c> */")).to be_truthy }
          it { expect(Tag.is_snippet_tag_line("# @snippet <repo:path/to/file.py>")).to be_truthy }
        end

        context "with repo start with `/`" do
          it { expect(Tag.is_snippet_tag_line("// @snippet <repo:/path/to/file.cpp>")).to be_truthy }
          it { expect(Tag.is_snippet_tag_line("/* @snippet <repo:/path/to/file.c> */")).to be_truthy }
          it { expect(Tag.is_snippet_tag_line("# @snippet <repo:/path/to/file.py>")).to be_truthy }
        end

        # TODO: add `@snippet <{repo}#{version}:{path}>`

      end # valid cases

      context "invalid cases" do
        it { expect(Tag.is_snippet_tag_line("// @snippet2 <path/to/file.cpp>")).to be_falsey }
        it { expect(Tag.is_snippet_tag_line("// @snippe <path/to/file.cpp>")).to be_falsey }
        it { expect(Tag.is_snippet_tag_line("// @snippet <path/to/file.cpp")).to be_falsey }
        it { expect(Tag.is_snippet_tag_line("// @snippet path/to/file.cpp>")).to be_falsey }
        it { expect(Tag.is_snippet_tag_line("/* @ snippet <path/to/file.c> */")).to be_falsey }
        it { expect(Tag.is_snippet_tag_line("# @snppet <path/to/file.py>")).to be_falsey }
      end

    end # is_snippet_tag_line

  end # Tag

end # SocialSnippet
