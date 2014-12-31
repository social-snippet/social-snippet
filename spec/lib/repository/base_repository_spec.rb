require "spec_helper"

module SocialSnippet::Repository::Drivers

  describe BaseRepository do

    describe "#to_snippet_json" do

      let(:instance) { BaseRepository.new "/path/to/repo" }

      before do
        FileUtils.mkdir_p "/path/to/repo"
        FileUtils.mkdir_p "/path/to/repo/my-src"
        FileUtils.touch   "/path/to/repo/snippet.json"

        File.write "/path/to/repo/snippet.json", [
          '{',
          '  "name": "my-name",',
          '  "desc": "my-desc",',
          '  "main": "my-src"',
          '}',
        ].join("\n")
      end # prepare /path/to/repo

      context "load snippet.json" do

        before { instance.load_snippet_json }
        let(:result) { JSON.parse(instance.to_snippet_json) }

        it { expect(result["name"]).to eq "my-name" }
        it { expect(result["desc"]).to eq "my-desc" }
        it { expect(result["main"]).to eq "my-src" }

      end # load snippet.json

    end # to_snippet_json

    describe "#glob" do

      let(:instance) { BaseRepository.new "/path/to/my-repo" }

      before do
        FileUtils.mkdir_p "/path/to/my-repo/"
        FileUtils.mkdir_p "/path/to/my-repo/.git/"
        FileUtils.mkdir_p "/path/to/my-repo/src/"
        FileUtils.mkdir_p "/path/to/my-repo/src/sub/"
        FileUtils.touch   "/path/to/my-repo/snippet.json"
        FileUtils.touch   "/path/to/my-repo/src/file.cpp"
        FileUtils.touch   "/path/to/my-repo/src/sub/sub_file_1.cpp"
        FileUtils.touch   "/path/to/my-repo/src/sub/sub_file_2.cpp"
        FileUtils.touch   "/path/to/my-repo/src/sub/sub_file_3.cpp"

        File.write "/path/to/my-repo/snippet.json", [
          '{',
          '  "name": "my-name",',
          '  "desc": "my-desc",',
          '  "main": "src"',
          '}',
        ].join("\n")
      end # prepare install_path

      context "load snippet.json" do

        before { instance.load_snippet_json }

        context "glob = file.cpp" do
          subject { instance.glob("file.cpp").map {|file_path| Pathname(file_path).basename.to_s } }
          it { should     include "file.cpp" }
          it { should_not include "sub_file_1.cpp" }
          it { should_not include "sub_file_2.cpp" }
          it { should_not include "sub_file_3.cpp" }
        end

        context "glob = file*" do
          subject { instance.glob("file*").map {|file_path| Pathname(file_path).basename.to_s } }
          it { should     include "file.cpp" }
          it { should_not include "sub_file_1.cpp" }
          it { should_not include "sub_file_2.cpp" }
          it { should_not include "sub_file_3.cpp" }
        end

        context "glob = sub/*" do
          subject { instance.glob("sub/*").map {|file_path| Pathname(file_path).basename.to_s } }
          it { should_not include "file.cpp" }
          it { should     include "sub_file_1.cpp" }
          it { should     include "sub_file_2.cpp" }
          it { should     include "sub_file_3.cpp" }
        end

        context "glob = sub/sub_file_2.*" do
          subject { instance.glob("sub/sub_file_2.*").map {|file_path| Pathname(file_path).basename.to_s } }
          it { should_not include "file.cpp" }
          it { should_not include "sub_file_1.cpp" }
          it { should     include "sub_file_2.cpp" }
          it { should_not include "sub_file_3.cpp" }
        end

      end # load snippet.json

    end # glob

  end # BaseRepository

end # SocialSnippet::Repository::Drivers
