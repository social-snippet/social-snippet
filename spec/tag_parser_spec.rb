require "spec_helper"

describe SocialSnippet::TagParser do

  describe "#find_snip_tags" do

    context "no @snip tags" do

      let(:input_text) do
        [
          'input text',
        ].join("\n")
      end

      it "returns an empty array" do
        expect(SocialSnippet::TagParser.find_snip_tags(input_text)).to eq []
      end

    end # no snip tags

    context "single @snip tag" do

      let(:input_text) do
        [
          '#include <stdio.h>',
          '',
          '// @snip <path/to/file.c>',
          '',
          'int main() {',
          '    func();',
          '    return 0;',
          '}',
        ].join("\n")
      end

      context "result" do

        let(:result) { SocialSnippet::TagParser.find_snip_tags(input_text) }
        
        it "has one element" do
          expect(result.length).to eq 1
        end

        context "line_no" do
          it { expect(result[0][:line_no]).to eq 2 }
        end

        context "tag.to_snippet_tag" do
          it { expect(result[0][:tag].to_snippet_tag).to eq "// @snippet <path/to/file.c>" }
        end

      end

    end # a snip tag

    context "multi @snip tags" do

      let(:input_text) do
        [
          '#include <stdio.h>',
          '',
          '// @snip <path/to/file1.c>',
          '// @snip <./path/to/file2.c>',
          '',
          'int main() {',
          '    func();',
          '    return 0;',
          '}',
        ].join("\n")
      end

      context "result" do

        let(:result) { SocialSnippet::TagParser.find_snip_tags(input_text) }

        it "has two elements" do
          expect(result.length).to eq 2
        end

        context "line_no" do
          it { expect(result[0][:line_no]).to eq 2 }
          it { expect(result[1][:line_no]).to eq 3 }
        end

        context "tag.to_snippet_tag" do
          it { expect(result[0][:tag].to_snippet_tag).to eq "// @snippet <path/to/file1.c>" }
          it { expect(result[1][:tag].to_snippet_tag).to eq "// @snippet <path/to/file2.c>"}
        end

      end

    end # multi snip tags

    context "@snip tags with repository" do

      let(:input_text) do
        [
          '# use repository',
          '# @snip <repo-a:path/to/file1.rb>',
          '# @snip  <repo-b:path/to/file1.rb>',
          '# @snip   <repo-b:/path/to/file2.rb>',
          '# @snippet <path/to/file3.rb>',
          '',
          'puts "hello"',
        ].join("\n")
      end

      context "result" do

        let(:result) { SocialSnippet::TagParser.find_snip_tags(input_text) }

        it "has three elements" do
          expect(result.length).to eq 3
        end

        context "line_no" do
          it { expect(result[0][:line_no]).to eq 1 }
          it { expect(result[1][:line_no]).to eq 2 }
          it { expect(result[2][:line_no]).to eq 3 }
        end

        context "tag.to_snippet_tag" do
          it { expect(result[0][:tag].to_snippet_tag).to eq "# @snippet <repo-a:path/to/file1.rb>" }
          it { expect(result[1][:tag].to_snippet_tag).to eq "# @snippet  <repo-b:path/to/file1.rb>" }
          it { expect(result[2][:tag].to_snippet_tag).to eq "# @snippet   <repo-b:path/to/file2.rb>" }
        end

      end

    end

  end # find_snip_tags

  describe "#find_snippet_tags" do

    context "@snip tags with repository" do

      let(:input_text) do
        [
          '# use repository',
          '# @snip <repo-a:path/to/file1.rb>',
          '# @snip  <repo-b:path/to/file1.rb>',
          '# @snip   <repo-b:/path/to/file2.rb>',
          '# @snippet <path/to/file3.rb>',
          '',
          'puts "hello"',
        ].join("\n")
      end

      context "result" do

        let(:result) { SocialSnippet::TagParser.find_snippet_tags(input_text) }

        it "has one element" do
          expect(result.length).to eq 1
        end

        context "line_no" do
          it { expect(result[0][:line_no]).to eq 4 }
        end

        context "tag.to_snip_tag" do
          it { expect(result[0][:tag].to_snip_tag).to eq "# @snip <path/to/file3.rb>" }
        end

      end

    end # snip tags with repository

  end # find_snippet_tags

end # SocialSnippet::TagParser

