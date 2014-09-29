require "spec_helper"

module SocialSnippet

  module Repository

    describe GitRepository, :use_raw_filesystem => true do

      context "github repo" do

        context "clone social-snippet/example-repo" do

          subject(:repo) { Repository.clone("git://github.com/social-snippet/example-repo.git") }

          context "load snippet.json" do
            before { repo.load_snippet_json }
            it { expect(repo.name).to eq "example-repo" }
          end

          describe "#get_refs" do
            subject { repo.get_refs }
            it { should include "master" }
            it { should include "1.0.0" }
            it { should include "1.0.1" }
          end

          describe "#get_versions" do
            subject { repo.get_versions }
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

            describe "#get_commit_id" do
              subject { repo.get_commit_id }
              it { should eq "efa58ecae07cf3d063ae75fa97fce164c56d205a" }
            end

            describe "#get_short_commit_id" do
              subject { repo.get_short_commit_id }
              it { should eq "efa58eca" }
            end

          end # checkout 1.0.0

          context "checkout 1.0.x (latest)" do

            before do
              repo.checkout(repo.get_latest_version("1.0"))
              repo.load_snippet_json
            end

            it { expect(repo.name).to eq "example-repo" }

            describe "#get_commit_id" do
              subject { repo.get_commit_id }
              it { should eq "073f4411f5251745b339d57356e2560f386e268c" }
            end

            describe "#get_short_commit_id" do
              subject { repo.get_short_commit_id }
              it { should eq "073f4411" }
            end

          end # checkout 1.0.x

        end # clone social_snippet/example-repo

      end # github repo

    end # GitRepository

  end # Repository

end # SocialSnippet

