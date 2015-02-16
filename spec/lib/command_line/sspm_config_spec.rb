require "spec_helper"

module SocialSnippet::CommandLine

  describe SSpm::SubCommands::ConfigCommand do

    describe "$ sspm config key" do

      let(:sspm_config_command) { SSpm::SubCommands::ConfigCommand.new ["key"] }

      it { expect(fake_core.api).to receive(:config_get).with("key").once }

      after do
        sspm_config_command.init
        sspm_config_command.run
      end

    end

    describe "$ sspm config key value" do

      let(:sspm_config_command) { SSpm::SubCommands::ConfigCommand.new ["key", "value"] }

      it { expect(fake_core.api).to receive(:config_set).with("key", "value").once }

      after do
        sspm_config_command.init
        sspm_config_command.run
      end

    end

    describe "$ sspm config key=value" do

      let(:sspm_config_command) { SSpm::SubCommands::ConfigCommand.new ["key=value"] }

      it { expect(fake_core.api).to receive(:config_set).with("key", "value").once }

      after do
        sspm_config_command.init
        sspm_config_command.run
      end

    end

  end # SSpm::MainCommand

end # SocialSnippet::CommandLine
