require "spec_helper"

module SocialSnippet

  describe Snippet do

    describe "#filter()" do

      context "cutting (cpp)" do

        let(:input) do
          [
            "// @begin_cut",
            "#include <test>",
            "// @end_cut",
            "",
            "int main() {",
            "  return 0;",
            "}",
          ]
        end

        let(:expected) do
          [
            "",
            "int main() {",
            "  return 0;",
            "}",
          ]
        end

        let(:snippet) { Snippet.new fake_core, nil }
        before { snippet.read_text input.join($/) }
        subject { snippet.lines }
        it { should eq expected }

      end

    end

  end # Snippet

end # SocialSnippet

