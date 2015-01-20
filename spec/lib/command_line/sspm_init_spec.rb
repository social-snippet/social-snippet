require "spec_helper"

module SocialSnippet::CommandLine

  describe SSpm::SubCommands::InitCommand, :current => true do

    describe "$ sspm init" do

      let(:sspm_init_command) { SSpm::SubCommands::InitCommand .new [] }

      example do
        expect(fake_social_snippet.api).to receive(:init_manifest).with({}).once
        sspm_init_command.init
        sspm_init_command.run
      end

    end

  end # SSpm::InitCommand

end # SocialSnippet::CommandLine
