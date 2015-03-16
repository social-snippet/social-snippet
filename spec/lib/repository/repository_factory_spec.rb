require "spec_helper"

describe ::SocialSnippet::Repository::DriverFactory do

  let(:driver_factory) { ::SocialSnippet::Repository::DriverFactory.new fake_core }

  class FakeGitDriver < ::SocialSnippet::Repository::Drivers::DriverBase

    def self.target_url?(s)
      /^git:\/\// === s
    end

    def fetch
    end

    def snippet_json
      {
        "name" => "fake-repo",
      }
    end

    def latest_version
      "1.2.3"
    end

    def rev_hash(ref)
      if ref === "1.2.3"
        "rev-1.2.3"
      else
        raise "error"
      end
    end

    def each_directory
      [
        ::SocialSnippet::Repository::Drivers::Entry.new("path"),
        ::SocialSnippet::Repository::Drivers::Entry.new("path/to"),
      ].each do |dir|
        yield dir
      end
    end

    def each_file
      [
        ::SocialSnippet::Repository::Drivers::Entry.new("snippet.json", {:name => "fake-repo"}.to_json),
        ::SocialSnippet::Repository::Drivers::Entry.new("path/to/file", "file"),
      ].each do |dir|
        yield dir
      end
    end

    def refs
      ["1.2.3"]
    end

  end

  context "reset drivers" do
  
    before { driver_factory.reset_drivers }

    context "add FakeGitDriver" do

      before { driver_factory.add_driver FakeGitDriver }

      context "clone git://github.com/user/repo" do
        let(:driver) { driver_factory.clone "git://github.com/user/repo" }
        it { expect(driver.snippet_json["name"]).to eq "fake-repo" }
      end

    end

  end

end # driver_factory

