require "spec_helper"

describe ::SocialSnippet::Repository::Drivers::GitDriver, :without_fakefs => true do

  context "github repo" do

    let(:repo_url) { "git://github.com/social-snippet/example-repo.git" }

    subject(:driver) do
      ::SocialSnippet::Repository::Drivers::GitDriver.new fake_core, repo_url
    end

    context "driver.fetch" do

      before { driver.fetch }

      describe "#refs" do
        subject { driver.refs }
        it { should include "master" }
        it { should include "1.0.0" }
        it { should include "1.0.1" }
      end #refs

      describe "#versions" do
        subject { driver.versions }
        it { should_not include "master" }
        it { should include "1.0.0" }
        it { should include "1.0.1" }
      end #versions

      describe "#latest_version" do
        context "latest_version 1.0" do
          subject { driver.latest_version("1.0") }
          it { should eq "1.0.2" }
        end
        context "latest_version 9.9" do
          subject { driver.latest_version("9.9") }
          it { should eq nil }
        end
      end #latest_version

    end # driver.fetch

  end # github repo

end # GitDriver

