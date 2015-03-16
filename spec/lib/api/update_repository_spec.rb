require "spec_helper"

describe ::SocialSnippet::Api::UpdateRepositoryApi, :current => true do

  class FakeDriver < ::SocialSnippet::Repository::Drivers::DriverBase
    def fetch; end

    def snippet_json
      {
        "name" => "my-repo"
      }
    end

    def rev_hash(ref)
      if refs.include?(ref)
        "rev-#{ref}"
      else
        raise "error"
      end
    end

    def each_directory(ref); end
    def each_content(ref); end
    def each_ref(&block)
      refs.each &block
    end

    @@refs = ["1.0.0"]

    def refs
      @@refs
    end

    def self.add_ref(ref)
      @@refs.push ref
    end

    def self.target_url?(url)
      "dummy" === ::URI.parse(url).scheme
    end
  end # class FakeDriver

  context "prepare driver" do

    before do
      fake_core.repo_factory.reset_drivers
      fake_core.repo_factory.add_driver FakeDriver
    end

    context "install my-repo#1.0.0" do
      before { fake_core.api.install_repository "dummy://driver.test/user/my-repo", "1.0.0" }
      it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.0").to be_truthy }
      it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.1").to be_falsey }
      context "add 1.0.1" do
        before { FakeDriver.add_ref "1.0.1" }
        context "update my-repo" do
          before { fake_core.api.update_repository "my-repo" }
          it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.0").to be_truthy }
          it { expect(fake_core.repo_manager.exists? "my-repo", "1.0.1").to be_truthy }
        end
      end
    end # install my-repo#1.0.0

  end # prepare driver

end # ::SocialSnippet::Api::UpdateRepositoryApi

