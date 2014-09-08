require "spec_helper"

module SocialSnippet

  describe Inserter do

    context "from empty" do

      let(:instance) { Inserter.new([]) }

      context "insert AAA" do

        before { instance.insert ['AAA'] }
        subject { instance.to_s }
        it { should eq "AAA" }

        context "insert BBB, CCC" do

          before { instance.insert ['BBB', 'CCC'] }
          subject { instance.to_s }

          let(:output) do
            [
              'AAA',
              'BBB',
              'CCC',
            ].join("\n")
          end

          it { should eq output }

          context "replace ABC" do

            before { instance.replace 'ABC' }
            subject { instance.to_s }

            let(:output) do
              [
                'AAA',
                'BBB',
                'ABC',
              ].join("\n")
            end

            it { should eq output }

            context "remove" do

              before { instance.remove }
              subject { instance.to_s }

              let(:output) do
                [
                  'AAA',
                  'BBB',
                ].join("\n")
              end

              it { should eq output }

              context "insert 1, 2, 3" do

                before { instance.insert ['1', '2', '3'] }
                subject { instance.to_s }

                let(:output) do
                  [
                    'AAA',
                    'BBB',
                    '1',
                    '2',
                    '3',
                  ].join("\n")
                end

                it { should eq output }

              end

            end # remove 

          end # replace ABC

        end # insert BBB, CCC

      end # insert AAA

    end # empty

  end # Inserter

end # SocialSnippet
