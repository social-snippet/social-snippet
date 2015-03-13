require "spec_helper"

describe ::SocialSnippet::CommandLine::SSpm::SubCommands::UpdateCommand do

  describe "$ sspm update" do

    context "prepare repositories" do

      before do
        ::SocialSnippet::Repository::Models::Repository.create(
          :name => "repo-1",
          :url => "url-repo-1",
        )
        ::SocialSnippet::Repository::Models::Repository.create(
          :name => "repo-2",
          :url => "url-repo-2",
        )
      end

      context "update all" do

        let(:update_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::UpdateCommand.new [] }

        example do
          expect(fake_core.api).to receive(:update_repository).with("repo-1", kind_of(::Hash)).once
          expect(fake_core.api).to receive(:update_repository).with("repo-2", kind_of(::Hash)).once
        end

        after do
          update_command.init
          update_command.run
        end

      end

      context "update repo-1" do

        let(:update_command) { ::SocialSnippet::CommandLine::SSpm::SubCommands::UpdateCommand.new ["repo-1"] }

        example do
          expect(fake_core.api).to receive(:update_repository).with("repo-1", kind_of(::Hash)).once
          expect(fake_core.api).to_not receive(:update_repository).with("repo-2", kind_of(::Hash))
        end

        after do
          update_command.init
          update_command.run
        end

      end

    end

  end

end

