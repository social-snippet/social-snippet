require "spec_helper"

module SocialSnippet::Repository::Drivers

  describe BaseRepository do

    describe "version" do

      context "new path/to/repo" do

        let(:repo) { BaseRepository.new('/path/to/repo') }

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

    describe "cache test" do

      let(:commit_id) { "thisisdummyyyyy" }

      context "there is a repo" do

        before do
          FileUtils.mkdir_p "/path/to/repo_1"
          FileUtils.mkdir_p "/path/to/repo_1/.git"
          FileUtils.touch "/path/to/repo_1/snippet.json"

          File.write "/path/to/repo_1/snippet.json", [
            '{',
            '  "name": "repo_1",',
            '  "desc": "this is repo_1",',
            '  "language": "Ruby"',
            '}',
          ].join($/)
        end

        context "create repo_1 instance" do

          let(:cache_path) { "/path/to/cache" }
          before { FileUtils.mkdir_p(cache_path) }

          let(:instance) do
            repo = BaseRepository.new("/path/to/repo_1")
            repo.load_snippet_json
            return repo
          end

          context "name" do
            subject { instance.name }
            it { should eq "repo_1" }
          end

          context "create cache" do
            before do
              expect(instance).to receive(:commit_id).and_return commit_id
              instance.create_cache(cache_path)
            end

            context "snippet.json" do
              let(:result) { JSON.parse File.read "#{cache_path}/repo_1/#{commit_id[0..7]}/snippet.json" }
              it { expect(result["name"]).to eq "repo_1" }
              it { expect(result["desc"]).to eq "this is repo_1" }
              it { expect(result["language"]).to eq "Ruby" }
            end

          end # create cache

        end # create repo_1 instance

      end # there is a repo

      context "there are three repos" do

        before do
          # create repo_1
          FileUtils.mkdir_p "/path/to/repo_1"
          FileUtils.mkdir_p "/path/to/repo_1/.git"
          FileUtils.touch "/path/to/repo_1/snippet.json"
          File.write "/path/to/repo_1/snippet.json", [
            '{',
            '  "name": "repo_1",',
            '  "desc": "this is repo_1",',
            '  "language": "Ruby"',
            '}',
          ].join($/)

          # create repo_b
          FileUtils.mkdir_p "/path/to/repo_b"
          FileUtils.mkdir_p "/path/to/repo_b/.git"
          FileUtils.touch "/path/to/repo_b/snippet.json"
          File.write "/path/to/repo_b/snippet.json", [
            '{',
            '  "name": "repo_b",',
            '  "desc": "this is repo_b",',
            '  "language": "Ruby"',
            '}',
          ].join($/)

          # create repo_3
          FileUtils.mkdir_p "/path/to/repo_3"
          FileUtils.mkdir_p "/path/to/repo_3/.git"
          FileUtils.touch "/path/to/repo_3/snippet.json"
          File.write "/path/to/repo_3/snippet.json", [
            '{',
            '  "name": "repo_3",',
            '  "desc": "this is repo_3",',
            '  "language": "Ruby"',
            '}',
          ].join($/)
        end # before 

        context "create three instances" do

          let(:instance_1) { BaseRepository.new("/path/to/repo_1") }
          let(:instance_b) { BaseRepository.new("/path/to/repo_b") }
          let(:instance_3) { BaseRepository.new("/path/to/repo_3") }

          before do
            instance_1.load_snippet_json
            instance_b.load_snippet_json
            instance_3.load_snippet_json
          end

          context "name" do
            it { expect(instance_1.name).to eq "repo_1" }
            it { expect(instance_b.name).to eq "repo_b" }
            it { expect(instance_3.name).to eq "repo_3" }
          end

          context "create cache" do

            # create cache dir
            let(:cache_path) { "/path/to/cache" }
            before { FileUtils.mkdir_p(cache_path) }

            before do
              expect(instance_1).to receive(:commit_id).and_return commit_id
              expect(instance_b).to receive(:commit_id).and_return commit_id
              expect(instance_3).to receive(:commit_id).and_return commit_id
            end

            before do
              instance_1.create_cache(cache_path)
              instance_b.create_cache(cache_path)
              instance_3.create_cache(cache_path)
            end

            context "snippet.json" do

              context "repo_1" do
                let(:result) do
                  JSON.parse File.read "#{cache_path}/repo_1/#{commit_id[0..7]}/snippet.json"
                end
                it { expect(result["name"]).to eq "repo_1" }
                it { expect(result["desc"]).to eq "this is repo_1" }
                it { expect(result["language"]).to eq "Ruby" }
              end

              context "repo_b" do
                let(:result) do
                  JSON.parse File.read "#{cache_path}/repo_b/#{commit_id[0..7]}/snippet.json"
                end
                it { expect(result["name"]).to eq "repo_b" }
                it { expect(result["desc"]).to eq "this is repo_b" }
                it { expect(result["language"]).to eq "Ruby" }
              end

              context "repo_3" do
                let(:result) do
                  JSON.parse File.read "#{cache_path}/repo_3/#{commit_id[0..7]}/snippet.json"
                end
                it { expect(result["name"]).to eq "repo_3" }
                it { expect(result["desc"]).to eq "this is repo_3" }
                it { expect(result["language"]).to eq "Ruby" }
              end

            end # snippet.json

          end # create cache

        end # create three instances 

      end # there are three repos

    end # .new

  end # BaseRepository

end # SocialSnippet::Repository

