require "spec_helper"

module ::SocialSnippet::CommandLine

  describe SSpm::SubCommands::InstallCommand do

    describe "has_ref?()" do

      let(:update_command) { SSpm::SubCommands::InstallCommand.new [] }

      describe "with ref" do
        it { expect(update_command.send :has_ref?, "hello#1.2.3").to be_truthy }
        it { expect(update_command.send :has_ref?, "example_repo#master").to be_truthy }
        it { expect(update_command.send :has_ref?, "example-repo#develop").to be_truthy }
      end

      describe "without ref" do
        it { expect(update_command.send :has_ref?, "hello").to be_falsey }
        it { expect(update_command.send :has_ref?, "example_repo").to be_falsey }
        it { expect(update_command.send :has_ref?, "example-repo").to be_falsey }
      end

    end # has_ref?

  end # SSpm::SubCommands::UpdateCommand

end # ::SocialSnippet::CommandLine

