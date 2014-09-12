require "spec_helper"

module SocialSnippet

  describe Inserter do

    context "new include, snip" do

      let(:instance) do
        Inserter.new [
          '#include <iostream>',
          '',
          '// @snip<my-repo:path/to/func.cpp>',
        ]
      end

      context "set_index 2" do

        before { instance.set_index 2 }

        context "ignore" do

          before { instance.ignore }

          let(:output) do
            [
              '#include <iostream>',
              '',
            ].join("\n").freeze
          end

          it { expect(instance.to_s).to eq output }

          context "insert snippet" do

            before do
              instance.insert [
                '// @snippet<my-repo:path/to/func.cpp>',
              ].freeze
            end

            let(:output) do
              [
                '#include <iostream>',
                '',
                '// @snippet<my-repo:path/to/func.cpp>',
              ].join("\n").freeze
            end

            it { expect(instance.to_s).to eq output }

            context "insert code, code, code" do

              before do
                instance.insert [
                  'code',
                  'code',
                  'code',
                ].freeze
              end

              let(:output) do
                [
                  '#include <iostream>',
                  '',
                  '// @snippet<my-repo:path/to/func.cpp>',
                  'code',
                  'code',
                  'code',
                ].join("\n").freeze
              end

              it { expect(instance.to_s).to eq output }

            end # insert code, code, code

          end # insert snippet

        end # ignore

      end # set_index 2

    end # new include, snip

    context "from empty" do

      let(:instance) { Inserter.new([]) }

      context "insert 1, 2, 3" do

        before do
          instance.insert [
            '1',
            '2',
            '3',
          ].freeze
        end

        let(:output) do
          [
            '1',
            '2',
            '3',
          ].join("\n").freeze
        end

        it { expect(instance.to_s).to eq output }

        context "ignore" do

          before { instance.ignore }

          let(:output) do
            [
              '1',
              '2',
              '3',
            ].join("\n").freeze
          end

          it { expect(instance.to_s).to eq output }

          context "insert a" do

            before do
              instance.insert [
                'a',
              ].freeze
            end

            let(:output) do
              [
                '1',
                '2',
                '3',
                'a',
              ].join("\n").freeze
            end

            it { expect(instance.to_s).to eq output }

          end # insert a

        end # ignore

      end # insert 1, 2, 3

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

        end # insert BBB, CCC

      end # insert AAA

    end # empty

  end # Inserter

end # SocialSnippet
