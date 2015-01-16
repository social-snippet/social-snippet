require "spec_helper"

describe SocialSnippet::Config, :without_fakefs => $WITHOUT_FAKEFS, :current => true do

  let(:logger) do
    logger = ::SocialSnippet::Logger.new(STDOUT)
    logger.level = ::SocialSnippet::Logger::Severity::UNKNOWN
    logger
  end

  let(:social_snippet) do
    class Fake; end
    Fake.new
  end

  let(:config) do
    ::SocialSnippet::Config.new(social_snippet)
  end

  before { stub_const "ENV", "HOME" => Dir.mktmpdir }

  describe "sspm_url" do

    context "set info" do
      before { config.set :sspm_host, "api.test" }
      before { config.set :sspm_protocol, "https" }
      before { config.set :sspm_version, "v0" }
      it { expect(config.sspm_url).to eq "https://api.test/api/v0" }
    end

  end # sspm_url

  describe "getter / setter" do

    context "get undefined key" do
      it { expect(config.get "this-is-undefined").to be_nil }
    end

    context "set key without saving" do

      before { config.set "key", "value1" }

      context "get key" do
        it { expect(config.get "key").to eq "value1" }
      end

      context "reload file" do

        before { config.load_file }

        context "get key" do
          it { expect(config.get "key").to be_nil }
        end

      end

    end # set key without saving

    context "set key with saving" do

      describe "set!()" do

        before { config.set! "key", "value" }

        context "reload file" do

          before { config.load_file }

          context "get key" do
            it { expect(config.get "key").to eq "value" }
          end

        end

      end

      describe "save_file()" do

        before do
          config.set "key", "value"
          config.save_file
        end

        context "reload file" do

          before { config.load_file }

          context "get key" do
            it { expect(config.get "key").to eq "value" }
          end

        end

      end

    end # set key with saving

  end # getter / setter

  describe "use default value" do

    it { expect(config.home).to eq ::File.join(ENV["HOME"], ".social-snippet") }
    it { expect(config.file_path).to eq ::File.join(ENV["HOME"], ".social-snippet", "config.json") }

  end # use default value

  context "set ENV[SOCIAL_SNIPPET_HOME]" do

    before { stub_const "ENV", "HOME" => Dir.mktmpdir, "SOCIAL_SNIPPET_HOME" => Dir.mktmpdir }
    it { expect(config.home).to_not eq ::File.join(ENV["HOME"], ".social-snippet") }
    it { expect(config.home).to eq ENV["SOCIAL_SNIPPET_HOME"] }
    it { expect(config.file_path).to eq ::File.join(ENV["SOCIAL_SNIPPET_HOME"], "config.json") }

  end # set ENV[SOCIAL_SNIPPET_HOME]

end # SocialSnippet::Config

