require "spec_helper"

module SocialSnippet::Repository::Drivers

  describe GitDriver, :without_fakefs => true do

    before { disable_fakefs }

    context "github repo" do

      context "clone social-snippet/example-repo" do

        subject(:repo) { fake_core.repo_factory.clone("git://github.com/social-snippet/example-repo.git") }

        context "load snippet.json" do
          before { repo.load_snippet_json }
          it { expect(repo.name).to eq "example-repo" }
        end

        describe "#refs" do
          subject { repo.refs }
          it { should include "master" }
          it { should include "1.0.0" }
          it { should include "1.0.1" }
        end

        describe "#versions" do
          subject { repo.versions }
          it { should_not include "master" }
          it { should include "1.0.0" }
          it { should include "1.0.1" }
        end

        context "checkout 1.0.0" do

          before do
            repo.checkout("1.0.0")
            repo.load_snippet_json
          end

          it { expect(repo.name).to eq "example-repo" }

          describe "#commit_id" do
            subject { repo.commit_id }
            it { should eq "efa58ecae07cf3d063ae75fa97fce164c56d205a" }
          end

          describe "#short_commit_id" do
            subject { repo.short_commit_id }
            it { should eq "efa58eca" }
          end

        end # checkout 1.0.0

        context "checkout 1.0.x (latest)" do

          before do
            repo.checkout(repo.latest_version("1.0"))
            repo.load_snippet_json
          end

          it { expect(repo.name).to eq "example-repo" }

          describe "#commit_id" do
            subject { repo.commit_id }
            it { should eq "38ebf733622174e24d76d28ab264c52b4fd7bda9" }
          end

          describe "#short_commit_id" do
            subject { repo.short_commit_id }
            it { should eq "38ebf733" }
          end

        end # checkout 1.0.x

      end # clone social_snippet/example-repo

    end # github repo

  end # GitDriver

end # SocialSnippet::Repository::Drivers

