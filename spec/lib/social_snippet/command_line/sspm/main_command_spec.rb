require "spec_helper"

module SocialSnippet::CommandLine::Sspm

  describe MainCommand do

    context "create instance" do

      describe "$ sspm search repo" do

        let(:instance) { MainCommand.new(["search", "repo"]) }

        before { instance.init }

        it "call $ search repo" do
          allow_any_instance_of(::SocialSnippet::CommandLine::Command).to receive(:init).and_return nil
          expect(SubCommands::SearchCommand).to receive(:new).with(["repo"]).once do
            command = ::SocialSnippet::CommandLine::Command.new([])
            expect(command).to receive(:run).once
            command
          end
          instance.run
        end

      end

    end

  end

end

