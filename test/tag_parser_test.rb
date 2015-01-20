require "spec_helper"

describe SocialSnippet::TagParser do

  describe "#find_snip_tags" do

    context "there are two @snip" do

      let(:input) do
        [
          "// @snip <path/to/file1.c>",
          "// @snip <path/to/file2.c>",
          "// @snippet <path/to/file3.c>",
        ].join($/)
      end

      context "result" do
        let(:result) { SocialSnippet::TagParser.find_snip_tags(input) }
        it { expect(result.length).to eq 2 }
      end

    end

  end # find_snip_tags

  describe "#find_snippet_tags" do

    context "there is a @snippet" do

      let(:input) do
        [
          "// @snip <path/to/file1.c>",
          "// @snip <path/to/file2.c>",
          "// @snippet <path/to/file3.c>",
        ].join($/)
      end

      context "result" do
        let(:result) { SocialSnippet::TagParser.find_snippet_tags(input) }
        it { expect(result.length).to eq 1 }
      end

    end

  end # find_snippet_tags

end # SocialSnippet::TagParser
