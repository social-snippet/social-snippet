require "spec_helper"

describe SocialSnippet::Config, :without_fakefs => $WITHOUT_FAKEFS do

  let(:logger) do
    logger = ::SocialSnippet::Logger.new(STDOUT)
    logger.level = ::SocialSnippet::Logger::Severity::UNKNOWN
    logger
  end

  let(:config) do
    ::SocialSnippet::Config.new(social_snippet)
  end

  let(:social_snippet) do
    class Fake; end
    Fake.new
  end

  describe "#new" do

    before { stub_const "ENV", "HOME" => Dir.mktmpdir }

    context "use default value" do

      let(:config) do
        ::SocialSnippet::Config.new(social_snippet)
      end

      context "#home" do
        subject { config.home }
        it { should eq "#{ENV["HOME"]}/.social-snippet" }
      end

    end # use default value

    context "set ENV[SOCIAL_SNIPPET_HOME]" do

      before { stub_const "ENV", "SOCIAL_SNIPPET_HOME" => Dir.mktmpdir }

      let(:config) do
        ::SocialSnippet::Config.new(social_snippet)
      end

      context "#home" do
        subject { config.home }
        it { should_not eq "#{ENV["HOME"]}/.social-snippet" }
        it { should eq ENV["SOCIAL_SNIPPET_HOME"] }
      end

    end # set ENV[SOCIAL_SNIPPET_HOME]

  end # new

end # SocialSnippet::Config

