require "spec_helper"

describe ::SocialSnippet::CommandLine::SSpm::SubCommands::UpdateCommand do

  describe "$ sspm update" do

    before { allow(fake_core.api).to receive(:update_repository) }

    context "prepare repositories" do

      before do
        ::SocialSnippet::Repository::Models::Repository.create(
          :name => "repo-1",
          :url => "url-repo-1",
        )
      end

      before do
        ::SocialSnippet::Repository::Models::Repository.create(
          :name => "repo-2",
          :url => "url-repo-2",
        )
      end

      context "update all" do

        let(:update_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::UpdateCommand.new [] }
        before { update_command.init }

        context "run command" do
          before { update_command.run }
          it { expect(fake_core.api).to have_received(:update_repository).with("repo-1", kind_of(::Hash)).once }
          it { expect(fake_core.api).to have_received(:update_repository).with("repo-2", kind_of(::Hash)).once }
        end

      end # update all

      context "update repo-1" do

        let(:update_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::UpdateCommand.new ["repo-1"] }
        before { update_command.init }

        context "run command" do
          before { update_command.run }
          it { expect(fake_core.api).to have_received(:update_repository).with("repo-1", kind_of(::Hash)).once }
          it { expect(fake_core.api).to_not have_received(:update_repository).with("repo-2", kind_of(::Hash)) }
        end

      end # update repo-1

    end # prepare repositories

  end # $ sspm update

end # ::SocialSnippet::CommandLine::SSpm::SubCommands::UpdateCommand

