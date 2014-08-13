require "spec_helper"

describe SocialSnippet::Tag do

  describe ".new()" do

    context "// @snip <path/to/file.cxx>" do

      let(:instance) { SocialSnippet::Tag.new("// @snip <path/to/file.cxx>") }

      context "to_snippet_tag()" do
        subject { instance.to_snippet_tag() }
        it { should eq "// @snippet <path/to/file.cxx>" }
      end

    end # snip <path/to/file.cxx>

    context "/* @snip <path/to/file.c> */" do

      let(:instance) { SocialSnippet::Tag.new("/* @snip <path/to/file.c> */") }

      context "to_snippet_tag()" do
        subject { instance.to_snippet_tag() }
        it { should eq "/* @snippet <path/to/file.c> */" }
      end

    end # snip <path/to/file.c>

    context "# @snippet          <many/spaces.py>" do

      let(:instance) { SocialSnippet::Tag.new("# @snippet          <many/space.py>") }

      context "to_snip_tag()" do
        subject { instance.to_snip_tag() }
        it { should eq "# @snip          <many/space.py>" }
      end

    end # snippet <many/spaces.py>

    context "// @snip <repo:use/repo.cpp>" do

      let(:instance) { SocialSnippet::Tag.new("// @snip <repo:use/repo.cpp>") }

      context "to_snippet_tag()" do
        subject { instance.to_snippet_tag() }
        it { should eq "// @snippet <repo:use/repo.cpp>" }
      end
 
    end # snip <repo:use/repo.cpp>

  end # .new()

end

