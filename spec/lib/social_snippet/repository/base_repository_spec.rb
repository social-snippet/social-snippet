require "spec_helper"

module SocialSnippet::Repository

  describe BaseRepository do

    before { FakeFS.activate! }
    after { FakeFS.deactivate!; FakeFS::FileSystem.clear }

    let(:instance) { BaseRepository.new "path/to/repo" }

    describe "#to_snippet_json" do

      before do
        FileUtils.mkdir_p "path/to/repo"
        FileUtils.mkdir_p "path/to/repo/my-src"
        FileUtils.touch   "path/to/repo/snippet.json"

        File.write "path/to/repo/snippet.json", [
          '{',
          '  "name": "my-name",',
          '  "desc": "my-desc",',
          '  "main": "my-src"',
          '}',
        ].join("\n")
      end # prepare path/to/repo

      context "load snippet.json" do

        before { instance.load_snippet_json }
        let(:result) { JSON.parse(instance.to_snippet_json) }

        it { expect(result["name"]).to eq "my-name" }
        it { expect(result["desc"]).to eq "my-desc" }
        it { expect(result["main"]).to eq "my-src" }

      end # load snippet.json

    end # to_snippet_json

  end # BaseRepository

end # SocialSnippet::Repository
