require "spec_helper"

describe ::SocialSnippet::Repository::Models::Repository, :current => true do

  let(:repo_url) { "git://github.com/user/my-repo" }
  let(:repo) do
    ::SocialSnippet::Repository::Models::Repository.new(
      :url => repo_url,
    )
  end

  before { ::SocialSnippet::Repository::Models::Repository.core = fake_core }

  describe "#add_ref" do
    context "add master" do
      before { repo.add_ref "master", "rev-master" }
      subject { repo.refs }
      it { should include "master" }
      it { expect(repo.rev_hash["master"]).to eq "rev-master" }
      context "add develop" do
        before { repo.add_ref "develop", "rev-develop" }
        subject { repo.refs }
        it { should include "develop" }
        it { expect(repo.rev_hash["master"]).to eq "rev-master" }
        it { expect(repo.rev_hash["develop"]).to eq "rev-develop" }
      end
    end
  end #add_ref

  describe "#versions" do
    subject { repo.versions }
    context "add master" do
      before { repo.add_ref "master", "rev-master" }
      it { should_not include "master" }
      context "add 1.2.3" do
        before { repo.add_ref "1.2.3", "rev-develop" }
        it { should_not be_empty }
        it { should include "1.2.3" }
      end
    end
  end #versions

  describe "#has_versions?" do
    subject { repo.has_versions? }
    context "add master" do
      before { repo.add_ref "master", "rev-master" }
      it { should be_falsey }
      context "add 1.2.3" do
        before { repo.add_ref "1.2.3", "rev-1.2.3" }
        it { should be_truthy}
      end
      context "add 4.5" do
        before { repo.add_ref "4.5", "rev-4.5" }
        it { should be_falsey }
      end
    end
  end #versions

  describe "#latest_version" do
    subject { repo.latest_version }
    context "add master" do
      before { repo.add_ref "master", "rev-master" }
      it { should be_nil }
      context "add 10.0.0" do
        before { repo.add_ref "10.0.0", "rev-10.0.0" }
        it { should eq "10.0.0" }
        context "add 10.0.1" do
          before { repo.add_ref "10.0.1", "rev-10.0.1" }
          it { should eq "10.0.1" }
          context "add 10.1.0" do
            before { repo.add_ref "10.1.0", "rev-10.1.0" }
            it { should eq "10.1.0" }
            context "add 9.999.9" do
              before { repo.add_ref "9.999.9", "rev-9.999.9" }
              it { should eq "10.1.0" }
              context "latest_version 9" do
                subject { repo.latest_version 9 }
                it { should eq "9.999.9" }
              end
            end
          end
        end
      end
    end
  end #latest_version

  describe "test persistence" do

    context "repo.name = my-repo" do

      before { repo.name = "my-repo" }

      context "save!" do

        before { repo.save! }

        context "find my-repo" do
          let(:my_repo) { ::SocialSnippet::Repository::Models::Repository.find_by :name => "my-repo" }
          it { expect(my_repo.name).to eq "my-repo" }
          it { expect(my_repo.url).to eq "git://github.com/user/my-repo" }
        end

      end # save repository

    end # repo.set_name my-repo

  end # test to store data

end # ::SocialSnippet::Repository::Models::Repository

