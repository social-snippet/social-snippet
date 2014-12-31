require "spec_helper"

describe ::SocialSnippet::Repository::RepositoryInstaller do

  let(:config) { ::SocialSnippet::Config.new(social_snippet) }

  let(:social_snippet) do
    class Fake; end
    Fake.new
  end

  before do
    allow(social_snippet).to receive(:config).and_return config
  end

  let(:installer) { ::SocialSnippet::Repository::RepositoryInstaller.new social_snippet }


  describe "#each()" do

    context "add four repos" do

      before do
        installer.add "my-repo-1", "0.0.1"
        installer.add "my-repo-2", "0.0.1"
        installer.add "my-repo-2", "0.0.2"
        installer.add "my-repo-3", "0.0.1"
      end # prepare for repos

      context "call each()" do
        it { expect {|b| installer.each &b }.to yield_successive_args("my-repo-1", "my-repo-2", "my-repo-3") }
      end

    end # add four repos

  end # each


  context "add my-repo#0.0.1" do

    before { installer.add "my-repo", "0.0.1" }

    context "installed my-repo#0.0.1" do
      subject { installer.exists? "my-repo", "0.0.1" }
      it { should be_truthy }

      context "remove my-repo#0.0.1" do
        before { installer.remove "my-repo", "0.0.1" }

        context "not installed my-repo#0.0.1" do

          subject { installer.exists? "my-repo", "0.0.1" }
          it { should be_falsey }

        end # not installed my-repo#0.0.1

      end # remove my-repo#0.0.1

    end # installed my-repo#0.0.1

  end # add my-repo#0.0.1

end # ::SocialSnippet::Repository::RepositoryInstaller
