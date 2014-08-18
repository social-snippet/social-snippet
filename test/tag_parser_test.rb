require "spec_helper"

describe SocialSnippet::TagParser do

  let(:instance) { SocialSnippet::TagParser.new() }

  describe "#find_snip_tags()" do

    context do

      let(:input) do
        [
          "// @snip <path/to/file1.c>",
          "// @snip <path/to/file2.c>",
          "// @snippet <path/to/file3.c>",
        ].join("\n")
      end

      context do
        let(:result) { instance.find_snip_tags(input) }
        it { expect(result.length).to eq 2 }
      end

    end

  end # find_snip_tags

end # SocialSnippet::TagParser
