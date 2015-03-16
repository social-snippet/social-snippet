require "spec_helper"

describe ::SocialSnippet::Repository::Drivers::DriverBase do

  describe "version" do

    context "new path/to/repo" do

      let(:repo) { ::SocialSnippet::Repository::Drivers::DriverBase.new("/path/to/repo") }

      context "version only cases" do

        context "has 0.0.1" do

          before do
            allow(repo).to receive(:refs).and_return([
              '0.0.1',
            ])
          end

          describe "versions" do
            let(:result) { repo.versions }
            it { expect(result.length).to eq 1 }
            it { expect(result).to include '0.0.1' }
          end # versions

          describe "latest_version" do
            it { expect(repo.latest_version).to eq '0.0.1' }
            it { expect(repo.latest_version('0')).to eq '0.0.1' }
            it { expect(repo.latest_version('0.0')).to eq '0.0.1' }
            it { expect(repo.latest_version('0.0.1')).to eq '0.0.1' }
            it { expect(repo.latest_version('1.0')).to be_nil }
          end # latest_version

        end # has 0.0.1

        context "has 0.0.1, 0.0.2, 0.0.3, 1.0.0" do
          
          before do
            allow(repo).to receive(:refs).and_return([
              '0.0.1',
              '0.0.2',
              '0.0.3',
              '1.0.0',
            ])
          end

          describe "versions" do

            let(:result) { repo.versions }

            it { expect(result.length).to eq 4 }

            context "check result" do
              subject { result }
              it { should include '0.0.1' }
              it { should include '0.0.2' }
              it { should include '0.0.3' }
              it { should include '1.0.0' }
            end

          end # versions

          describe "latest_version" do
            it { expect(repo.latest_version).to eq '1.0.0' }
            it { expect(repo.latest_version('0')).to eq '0.0.3' }
            it { expect(repo.latest_version('0.0')).to eq '0.0.3' }
            it { expect(repo.latest_version('1')).to eq '1.0.0' }
            it { expect(repo.latest_version('0.1')).to be_nil }
          end # latest_version

        end # has 0.0.1, 0.0.2, 0.0.3, 1.0.0

        context "has 1.2.3, 100.2.300, 123.456.789" do
          
          before do
            allow(repo).to receive(:refs).and_return([
              '1.2.3',
              '100.2.300',
              '123.456.789',
            ])
          end

          describe "versions" do

            let(:result) { repo.versions }

            it { expect(result.length).to eq 3 }

            context "check result" do
              subject { result }
              it { should include '1.2.3' }
              it { should include '100.2.300' }
              it { should include '123.456.789' }
            end

          end # versions

          describe "latest_version" do
            it { expect(repo.latest_version).to eq '123.456.789' }
            it { expect(repo.latest_version('0')).to be_nil }
            it { expect(repo.latest_version('0.0')).to be_nil }
            it { expect(repo.latest_version('1')).to eq '1.2.3' }
            it { expect(repo.latest_version('100')).to eq '100.2.300' }
            it { expect(repo.latest_version('100.2')).to eq '100.2.300' }
            it { expect(repo.latest_version('123')).to eq '123.456.789' }
            it { expect(repo.latest_version('123.456')).to eq '123.456.789' }
          end # latest_version

        end # has 1.2.3, 100.2.300, 123.456.789

      end # version only cases

      context "include not version cases" do

        context "has master, develop, 0.0.1, 0.1.0, 1.0.0" do

          before do
            allow(repo).to receive(:refs).and_return([
              'master',
              'develop',
              '0.0.1',
              '0.1.0',
              '1.0.0',
            ])
          end

          describe "versions" do
            let(:result) { repo.versions }

            it { expect(result.length).to eq 3 }

            context "check result" do
              subject { result }
              it { should include '0.0.1' }
              it { should include '0.1.0' }
              it { should include '1.0.0' }
            end
          end # versions

          describe "latest_version" do
            it { expect(repo.latest_version).to eq '1.0.0' }
            it { expect(repo.latest_version('0')).to eq '0.1.0' }
            it { expect(repo.latest_version('0.0')).to eq '0.0.1' }
            it { expect(repo.latest_version('1')).to eq '1.0.0' }
            it { expect(repo.latest_version('100')).to be_nil }
            it { expect(repo.latest_version('100.2')).to be_nil }
            it { expect(repo.latest_version('123')).to be_nil}
            it { expect(repo.latest_version('123.456')).to be_nil }
            it { expect(repo.latest_version('master')).to be_nil }
            it { expect(repo.latest_version('develop')).to be_nil }
          end # latest_version

        end # has master, develop, 0.0.1, 0.1.0, 1.0.0

        context "has master, feature/0.0.1, 0.0.1/test, 001, 0.0, 1, 1.2.3" do

          before do
            allow(repo).to receive(:refs).and_return([
              'master',
              'feature/0.0.1',
              '0.0.1/test',
              '001',
              '0.0',
              '1',
              '1.2.3',
            ])
          end

          describe "versions" do

            let(:result) { repo.versions }

            it { expect(result.length).to eq 1 }
            it { expect(result).to include '1.2.3' }

          end # versions

          describe "latest_version" do
            it { expect(repo.latest_version).to eq '1.2.3' }
            it { expect(repo.latest_version('0')).to be_nil }
            it { expect(repo.latest_version('0.0')).to be_nil }
            it { expect(repo.latest_version('1')).to eq '1.2.3' }
            it { expect(repo.latest_version('100')).to be_nil }
            it { expect(repo.latest_version('100.2')).to be_nil }
            it { expect(repo.latest_version('123')).to be_nil}
            it { expect(repo.latest_version('123.456')).to be_nil }
            it { expect(repo.latest_version('master')).to be_nil }
            it { expect(repo.latest_version('develop')).to be_nil }
          end # latest_version

        end # has master, feature/0.0.1, 0.0.1/test, 001, 0.0, 1, 1.2.3

      end # include not version cases

    end # new path/to/repo

  end # versions

end # ::SocialSnippet::Repository::Drivers::DriverBase

