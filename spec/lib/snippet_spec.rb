require "spec_helper"

describe ::SocialSnippet::Snippet, :current => true do

  describe "snippet.css" do

    context "prepare snippet" do

      let(:snippet) do
        ::SocialSnippet::Snippet.new_text fake_core, [
          "line-1",
          "line-2",
          "line-3",
        ].join($/)
      end

      context "no styles" do
        subject { snippet.lines }
        let(:expected) do
          [
            "line-1",
            "line-2",
            "line-3",
          ]
        end
        it { should eq expected }
      end

    end # prepare snippet

  end # snippet.css

end # ::SocialSnippet::Snippet

