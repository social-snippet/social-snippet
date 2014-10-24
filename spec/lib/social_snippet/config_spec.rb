require "spec_helper"

describe SocialSnippet::Config do

  describe "#new" do

    context "use default value" do

      before { ENV.delete "SOCIAL_SNIPPET_HOME" }

      let(:config) do
        SocialSnippet::Config.new
      end

      context "#home" do
        subject { config.home }
        it { should eq "#{ENV["HOME"]}/.social-snippet" }
      end

    end # use default value

    context "ENV[SOCIAL_SNIPPET_HOME] = /path/to/home" do

      before { ENV["SOCIAL_SNIPPET_HOME"] = "/path/to/home" }
      after { ENV.delete "SOCIAL_SNIPPET_HOME" }

      let(:config) do
        SocialSnippet::Config.new
      end

      context "#home" do
        subject { config.home }
        it { should eq "/path/to/home" }
      end

    end # ENV[SOCIAL_SNIPPET_HOME] = /path/to/home

  end # new

end # SocialSnippet::Config

