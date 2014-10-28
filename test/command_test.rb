require "spec_helper"

module SocialSnippet::CommandLine

  describe Command do

    let(:instance) { Command.new ["--opt1", "--opt2", "--opt3", "not-opt"] }

    describe :is_line_option do

      let(:func) do
        Proc.new do |name|
          instance.send(:is_line_option?, name)
        end
      end

      context "valid" do

        it { expect(func.call "--line-option").to be_truthy }
        it { expect(func.call "-l").to be_truthy }
        it { expect(func.call "--option1").to be_truthy }
        it { expect(func.call "--option_a").to be_truthy }

      end

      context "invalid" do

        it { expect(func.call "-too-long").to be_falsey }
        it { expect(func.call "opt").to be_falsey }
        it { expect(func.call "not-opt").to be_falsey }

      end

    end

  end # Command

end # SocialSnippet::CommandLine

