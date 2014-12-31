require "spec_helper"

module SocialSnippet::Repository

  describe RepositoryFactory do

    describe "#is_git_repo" do

      context "git protocol" do
        context "git://url/to/repo" do
          it { expect(RepositoryFactory.is_git_repo(URI.parse("git://url/to/repo"))).to be_truthy }
        end
      end # git protocol

      context "github.com" do
        context "git://" do
          it { expect(RepositoryFactory.is_git_repo(URI.parse("git://github.com/user/repo"))).to be_truthy }
        end
        context "http://" do
          it { expect(RepositoryFactory.is_git_repo(URI.parse("http://github.com/user/repo"))).to be_truthy }
        end
        context "https://" do
          it { expect(RepositoryFactory.is_git_repo(URI.parse("https://github.com/user/repo"))).to be_truthy }
        end
      end # github.com

    end # is_git_repo

  end # RepositoryFactory

end # SocialSnippet::Repository
