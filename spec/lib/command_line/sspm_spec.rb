require "spec_helper"

module SocialSnippet::CommandLine

  describe SSpm::MainCommand do

    describe "$ sspm search repo" do

      let(:sspm_command) { SSpm::MainCommand.new ["search", "repo"] }

      example do
        expect(sspm_command).to receive(:call_subcommand).with(:SearchCommand).once
        sspm_command.init
        sspm_command.run
      end

    end

    describe "$ sspm complete" do

      let(:sspm_command) { SSpm::MainCommand.new ["complete", "// @snip <repo"] }

      example do
        expect(sspm_command).to receive(:call_subcommand).with(:CompleteCommand).once
        sspm_command.init
        sspm_command.run
      end

    end

    describe "$ sspm install my-repo" do

      let(:sspm_command) { SSpm::MainCommand.new ["install", "my-repo"] }

      example do
        expect(sspm_command).to receive(:call_subcommand).with(:InstallCommand).once
        sspm_command.init
        sspm_command.run
      end

    end

    describe "$ sspm update" do

      let(:sspm_command) { SSpm::MainCommand.new ["update"] }

      example do
        expect(sspm_command).to receive(:call_subcommand).with(:UpdateCommand).once
        sspm_command.init
        sspm_command.run
      end

    end

    describe "$ sspm publish {url}" do

      let(:sspm_command) { SSpm::MainCommand.new ["publish", "https://github.com/user/repo"] }

      example do
        expect(sspm_command).to receive(:call_subcommand).with(:PublishCommand).once
        sspm_command.init
        sspm_command.run
      end

    end

    describe "$ sspm info {repo-name}" do

      let(:sspm_command) { SSpm::MainCommand.new ["info", "my-repo"] }

      example do
        expect(sspm_command).to receive(:call_subcommand).with(:InfoCommand).once
        sspm_command.init
        sspm_command.run
      end

    end

  end # SSpm::MainCommand

end # SocialSnippet::CommandLine
