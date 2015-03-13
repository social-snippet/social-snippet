require "spec_helper"

describe ::SocialSnippet::Repository::Drivers::GitDriver, :without_fakefs => true do

  before do
    fake_core.repo_factory.add_driver ::SocialSnippet::Repository::Drivers::GitDriver
  end

  context "github repo" do

    context "clone social-snippet/example-repo" do

      subject(:driver) { fake_core.repo_factory.clone("git://github.com/social-snippet/example-repo.git") }
      it { expect(driver.repo.name).to eq "example-repo" }

      describe "#refs" do
        subject { driver.repo.refs }
        it { should include "master" }
        it { should include "1.0.0" }
        it { should include "1.0.1" }
      end

      describe "#versions" do
        subject { driver.repo.versions }
        it { should_not include "master" }
        it { should include "1.0.0" }
        it { should include "1.0.1" }
      end

      describe "#latest_version" do
        subject { driver.repo.latest_version("1.0") }
        it { should eq "1.0.2" }
      end

    end # clone social_snippet/example-repo

  end # github repo

end # GitDriver

