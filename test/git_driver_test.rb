require "spec_helper"

describe ::SocialSnippet::Repository::Drivers::GitDriver, :without_fakefs => true do

  let(:driver) do
    url = "git://github.com/social-snippet/example-repo"
    ::SocialSnippet::Repository::Drivers::GitDriver.new url
  end

  context "fetch" do

    before { driver.fetch }

    context "has versions" do
      subject { driver.has_versions? }
      it { should be_truthy }
    end # has versions

    context "versions" do
      subject { driver.versions }
      it { should_not include "master" }
      it { should include "1.0.0" }
      it { should include "1.0.1" }
      it { should include "1.0.2" }
    end

    context "tags" do
      subject { driver.tags }
      it { should_not include "master" }
      it { should include "1.0.0" }
      it { should include "1.0.1" }
      it { should include "1.0.2" }
    end

    context "refs" do
      subject { driver.refs }
      it { should include "master" }
      it { should include "1.0.0" }
      it { should include "1.0.1" }
      it { should include "1.0.2" }
    end

    context "snippet_json" do
      subject { driver.snippet_json }
      it { expect(driver.snippet_json["name"]).to eq "example-repo" }
    end

  end # fetch

end # ::SocialSnippet::Repository::Drivers::GitDriver

