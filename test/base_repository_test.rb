require "spec_helper"

module SocialSnippet::Repository

  describe SocialSnippet::Repository::BaseRepository do

    # enable FakeFS
    before { FakeFS.activate! }
    after { FakeFS.deactivate! }

    describe ".new" do

      let(:commit_id) { "thisisdummyyyyy" }

      context "there is a repo" do

        before do
          # create files
          FileUtils.mkdir_p "/path/to/repo_1"
          FileUtils.mkdir_p "/path/to/repo_1/.git"
          FileUtils.touch "/path/to/repo_1/snippet.json"
          File.write "/path/to/repo_1/snippet.json", [
            '{',
            '  "name": "repo_1",',
            '  "desc": "this is repo_1",',
            '  "language": "Ruby"',
            '}',
          ].join("\n")
        end

        context "create repo_1 instance" do

          let(:instance) { BaseRepository.new("/path/to/repo_1") }

          before { instance.load_snippet_json }

          context "name" do
            subject { instance.name }
            it { should eq "repo_1" }
          end

          context "create cache" do
            before do
              # dummy commit id
              expect(instance).to receive(:get_commit_id).and_return commit_id
            end

            let(:cache_path) { "/path/to/cache" }
            before { FileUtils.mkdir_p(cache_path) }
            before { instance.create_cache(cache_path) }

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
          ].join("\n")

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
          ].join("\n")

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
          ].join("\n")
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
              expect(instance_1).to receive(:get_commit_id).and_return commit_id
              expect(instance_b).to receive(:get_commit_id).and_return commit_id
              expect(instance_3).to receive(:get_commit_id).and_return commit_id
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

    describe ".is_version" do

      context "valid cases" do
        it { expect(BaseRepository.is_version("0.0.1")).to be_truthy }
        it { expect(BaseRepository.is_version("1.2.3")).to be_truthy }
        it { expect(BaseRepository.is_version("1.2.345")).to be_truthy }
        it { expect(BaseRepository.is_version("123.4.5")).to be_truthy }
        it { expect(BaseRepository.is_version("9.9.9")).to be_truthy }
        it { expect(BaseRepository.is_version("1.234.5")).to be_truthy }
        it { expect(BaseRepository.is_version("123.456.7")).to be_truthy }
        it { expect(BaseRepository.is_version("1.234.567")).to be_truthy }
        it { expect(BaseRepository.is_version("123.4.567")).to be_truthy }
        it { expect(BaseRepository.is_version("123.456.789")).to be_truthy }
        it { expect(BaseRepository.is_version("12.34.56")).to be_truthy }
      end # valid cases

      context "invalid cases" do
        it { expect(BaseRepository.is_version("001.1")).to be_falsey }
        it { expect(BaseRepository.is_version("1.2.")).to be_falsey }
        it { expect(BaseRepository.is_version(".2.345")).to be_falsey }
        it { expect(BaseRepository.is_version("12345")).to be_falsey }
        it { expect(BaseRepository.is_version("9..9")).to be_falsey }
        it { expect(BaseRepository.is_version("..")).to be_falsey }
        it { expect(BaseRepository.is_version(".")).to be_falsey }
        it { expect(BaseRepository.is_version("1234567")).to be_falsey }
        it { expect(BaseRepository.is_version(".4.")).to be_falsey }
        it { expect(BaseRepository.is_version("01.2.3")).to be_falsey }
        it { expect(BaseRepository.is_version("1.2.03")).to be_falsey }
        it { expect(BaseRepository.is_version("1.02.3")).to be_falsey }
        it { expect(BaseRepository.is_version("1")).to be_falsey }
      end # invalid cases

    end # is_version

  end # SocialSnippet::Repository::BaseRepository

end # SocialSnippet::Repository

