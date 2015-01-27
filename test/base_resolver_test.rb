require "spec_helper"

module SocialSnippet::Resolvers

  describe BaseResolver, :current => true do

    let(:resolver) { BaseResolver.new(fake_social_snippet) }

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

        subject { resolver.filter(input) }
        it { should eq expected }

      end

    end

  end # BaseResolver

end # SocialSnippet::Resolvers
