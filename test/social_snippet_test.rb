require "spec_helper"

describe SocialSnippet::SocialSnippet do

  # Enable FakeFS
  before { FakeFS.activate! }
  after { FakeFS.deactivate!; FakeFS::FileSystem.clear }

  let(:instance) { SocialSnippet::SocialSnippet.new }
  let(:repo_manager) { SocialSnippet::RepositoryManager.new(SocialSnippet::Config.new) }
  let(:repo_path) { "#{ENV["HOME"]}/.social-snippet/repo" }
  let(:tmp_repo_path) { "/tmp/repos" }
  let(:tmp_repo_path_no_ver) { "/tmp/repos_no_ver" }
  let(:repo_cache_path) { "#{ENV["HOME"]}/.social-snippet/repo_cache" }
  let(:commit_id) { "thisisdummy" }
  let(:short_commit_id) { commit_id[0..7] }

  before { allow(instance).to receive(:repo_manager).and_return repo_manager }

  def find_repo_mock
    repo_versions = {}
    repos = Dir.glob("#{tmp_repo_path}/*").map{|path| Pathname.new(path).basename.to_s }
    repos.each do |repo_name|
      repo_versions[repo_name] = Dir.glob("#{tmp_repo_path}/#{repo_name}/*").map {|path| Pathname.new(path).basename.to_s }
    end

    repos_no_ver = Dir.glob("#{tmp_repo_path_no_ver}/*").map {|path| Pathname.new(path).basename.to_s }

    allow(repo_manager).to receive(:find_repository).with(any_args) do |repo_name, ref|
      repo_versions[repo_name] ||= []
      if repos_no_ver.include?(repo_name)
        repo_path = "#{tmp_repo_path_no_ver}/#{repo_name}"
      else
        base_repo_path = "#{tmp_repo_path}/#{repo_name}/#{repo_versions[repo_name].first}"
        base_repo = SocialSnippet::Repository::GitRepository.new(base_repo_path)
        allow(base_repo).to receive(:get_refs).and_return repo_versions[repo_name]
        base_repo.load_snippet_json
        repo_version = base_repo.get_latest_version ref
        repo_path = "#{tmp_repo_path}/#{repo_name}/#{repo_version}"
      end
      repo = SocialSnippet::Repository::GitRepository.new(repo_path)
      allow(repo).to receive(:get_refs).and_return repo_versions[repo_name]
      allow(repo).to receive(:get_commit_id).and_return "#{repo_version}#{commit_id}"
      repo.load_snippet_json
      repo.create_cache repo_cache_path
      repo
    end
  end

  describe "#insert_snippet" do

    context "use parent path" do

      before do
        repo_name = "my-repo"
        ref_name = "1.2.3"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/file_1"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_a"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_a/file_2"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_b"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_b/file_3"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_c"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_c/file_4"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/file_1", [
          '@snip<subdir_a/file_2>',
          'file_1',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_a/file_2", [
          '@snip<../subdir_b/file_3>',
          'file_2',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_b/file_3", [
          '@snip<../subdir_c/file_4>',
          'file_3',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_c/file_4", [
          'file_4',
        ].join("\n")
      end # prepare my-repo#1.2.3

      before { find_repo_mock }

      context "snip my-repo:file_1" do

        let(:input) do
          [
            '@snip <my-repo:file_1>',
            'main',
          ].join("\n").freeze
        end

        let(:output) do
          [
            '@snippet <my-repo#1.2.3:subdir_c/file_4>',
            'file_4',
            '@snippet <my-repo#1.2.3:subdir_b/file_3>',
            'file_3',
            '@snippet <my-repo#1.2.3:subdir_a/file_2>',
            'file_2',
            '@snippet <my-repo#1.2.3:file_1>',
            'file_1',
            'main',
          ].join("\n").freeze
        end

        subject { instance.insert_snippet input }
        it { should eq output }

      end

    end # use parent path

    context "snip self" do

      before do
        repo_name = "directly"
        ref_name = "3.2.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1", [
          '@snip<1>',
          '1',
        ].join("\n")
      end # prepare directly#3.2.1

      before do
        repo_name = "loop-1"
        ref_name = "1.1.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop", [
          '@snip<loop-2:loop>',
          'loop-1',
        ].join("\n")
      end # prepare loop-1#1.1.1

      before do
        repo_name = "loop-2"
        ref_name = "1.1.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop", [
          '@snip<loop-3:loop>',
          'loop-2',
        ].join("\n")
      end # prepare loop-2#1.1.1

      before do
        repo_name = "loop-3"
        ref_name = "1.1.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop", [
          '@snip<loop-1:loop>',
          '@snip<non-loop-4:non-loop>',
          'loop-3',
        ].join("\n")
      end # prepare loop-3#1.1.1

      before do
        repo_name = "non-loop-4"
        ref_name = "1.1.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/non-loop"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/non-loop", [
          'non-loop-4',
        ].join("\n")
      end # prepare non-loop-4#1.1.1

      before { find_repo_mock }

      context "indirectly" do

        context "has cyclic loop" do

          let(:input) do
            [
              '@snip<loop-1:loop>',
              'main',
            ].join("\n")
          end

          let(:output) do
            [
              '@snippet<non-loop-4#1.1.1:non-loop>',
              'non-loop-4',
              '@snippet<loop-3#1.1.1:loop>',
              'loop-3',
              '@snippet<loop-2#1.1.1:loop>',
              'loop-2',
              '@snippet<loop-1#1.1.1:loop>',
              'loop-1',
              'main',
            ].join("\n")
          end

          subject { instance.insert_snippet input }
          it { should eq output }

        end # has loop

      end # indirectly

      context "directly" do

        context "snip directly:1" do

          let(:input) do
            [
              '@snip<directly:1>',
            ].join("\n").freeze
          end

          let(:output) do
            [
              '@snippet<directly#3.2.1:1>',
              '1',
            ].join("\n")
          end

          subject { instance.insert_snippet input }
          it { should eq output }

        end

      end # directly

    end # snip self

    context "snippet snippet ... snippet" do

      before do
        repo_name = "my-repo-1"
        ref_name = "0.0.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1", [
          '@snip<my-repo-2#0:2>',
          'my-repo-1:1',
        ].join("\n")
      end # prepare my-repo-1

      before do
        repo_name = "my-repo-2"
        ref_name = "0.0.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2", [
          '@snip<my-repo-3:path/to/3>',
          'my-repo-2:2',
        ].join("\n")
      end # prepare my-repo-2#0.0.1

      before do
        repo_name = "my-repo-2"
        ref_name = "1.2.3"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2", [
          'miss!!',
        ].join("\n")
      end # prepare my-repo-2#1.2.3

      before do
        repo_name = "my-repo-3"
        ref_name = "1.2.3"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/path"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/path/to"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/path/to/3"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/path/to/3", [
          '@snip<my-repo-4:path/to/4>',
          'my-repo-3:path/to/3',
        ].join("\n")
      end # prepare my-repo-3#1.2.3

      before do
        repo_name = "my-repo-4"
        ref_name = "1.2.3"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/4"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/4", [
          '@snip<my-repo-5:path/to/5>',
          'my-repo-4:sources/path/to/4',
        ].join("\n")
      end # prepare my-repo-4#1.2.3

      before do
        repo_name = "my-repo-5"
        ref_name = "100.200.300"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/5"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/5", [
          '@snip<my-repo-6:path/to/6>',
          'my-repo-5:sources/path/to/5',
        ].join("\n")
      end # prepare my-repo-5#100.200.300

      before do
        repo_name = "my-repo-5"
        ref_name = "99.999.999"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/5"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/5", [
          'miss!!',
          'my-repo-5:5',
        ].join("\n")
      end # prepare my-repo-5#99.999.999

      before do
        repo_name = "my-repo-6"

        FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/.git"
        FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json"
        FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/sources"
        FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/sources/path"
        FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/sources/path/to"
        FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/sources/path/to/6"

        # snippet.json
        File.write "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join("\n")

        File.write "#{tmp_repo_path_no_ver}/#{repo_name}/sources/path/to/6", [
          '@snip<my-repo-7:path/to/7>',
          'my-repo-6:sources/path/to/6',
        ].join("\n")
      end # prepare my-repo-6

      before do
        repo_name = "my-repo-7"
        ref_name = "1.2.3"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/7"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/7", [
          'end',
          'my-repo-7:sources/path/to/7',
        ].join("\n")
      end # prepare my-repo-7#1.2.3

      before { find_repo_mock }

      context "snip my-repo-1:1" do

        let(:input) do
          [
            '/* @snip <my-repo-1:1> */',
          ].join("\n").freeze
        end

        let(:output) do
          [
            '/* @snippet <my-repo-7#1.2.3:path/to/7> */',
            'end',
            'my-repo-7:sources/path/to/7',
            '/* @snippet <my-repo-6#thisisdu:path/to/6> */',
            'my-repo-6:sources/path/to/6',
            '/* @snippet <my-repo-5#100.200.300:path/to/5> */',
            'my-repo-5:sources/path/to/5',
            '/* @snippet <my-repo-4#1.2.3:path/to/4> */',
            'my-repo-4:sources/path/to/4',
            '/* @snippet <my-repo-3#1.2.3:path/to/3> */',
            'my-repo-3:path/to/3',
            '/* @snippet <my-repo-2#0.0.1:2> */',
            'my-repo-2:2',
            '/* @snippet <my-repo-1#0.0.1:1> */',
            'my-repo-1:1',
          ].join("\n").freeze
        end

        subject { instance.insert_snippet input }
        it { should eq output }

      end # snip my-repo-1:1

    end # snippet snippet ... snippet

    context "snippet snippets" do

      before do
        repo_name = "my-repo"
        ref_name = "0.0.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/3"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/4"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/5"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/6"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/7"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/8"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/9"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1", [
          '@snip<5>',
          '@snip<4>',
          '@snip<3>',
          '@snip<2>',
          '1',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2", [
          '@snip<9>',
          '@snip<8>',
          '@snip<7>',
          '@snip<6>',
          '2',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/3", [
          '3',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/4", [
          '4',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/5", [
          '5',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/6", [
          '6',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/7", [
          '7',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/8", [
          '8',
        ].join("\n")

        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/9", [
          '9',
        ].join("\n")
      end

      before { find_repo_mock }

      let(:input) do
        [
          '@snip<my-repo:1>',
          'main',
        ].join("\n").freeze
      end

      let(:output) do
        [
          '@snippet<my-repo#0.0.1:5>',
          '5',
          '@snippet<my-repo#0.0.1:4>',
          '4',
          '@snippet<my-repo#0.0.1:3>',
          '3',
          '@snippet<my-repo#0.0.1:9>',
          '9',
          '@snippet<my-repo#0.0.1:8>',
          '8',
          '@snippet<my-repo#0.0.1:7>',
          '7',
          '@snippet<my-repo#0.0.1:6>',
          '6',
          '@snippet<my-repo#0.0.1:2>',
          '2',
          '@snippet<my-repo#0.0.1:1>',
          '1',
          'main',
        ].join("\n")
      end

      subject { instance.insert_snippet input }
      it { should eq output }

    end # snippet snippets

    context "use multiple repos and multiple versions" do

      before do
        repo_name = "my-repo"
        ref_name = "0.0.3"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'OK',
        ].join("\n")

        # src/2.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          '0.0.3',
        ].join("\n")

      end # prepare my-repo#0.0.3

      before do
        repo_name = "my-repo"
        ref_name = "0.0.2"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'ERROR_CASE',
        ].join("\n")

      end # prepare my-repo#0.0.2

      before do
        repo_name = "my-repo"
        ref_name = "0.0.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'ERROR_CASE',
        ].join("\n")

      end # prepare my-repo#0.0.1

      before do
        repo_name = "my-repo"
        ref_name = "1.0.0"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'THIS_IS_OK',
        ].join("\n")
      end # prepare my-repo#1.0.0

      before do
        repo_name = "new-my-repo"
        ref_name = "0.0.1"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          'OLD VERSION',
        ].join("\n")
      end # prepare new-my-repo#0.0.1

      before do
        repo_name = "new-my-repo"
        ref_name = "0.0.2"

        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"
        FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/3.rb"

        # snippet.json
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip <my-repo#0:1.rb>',
          '# @snip </2.rb>',
          '# @snip <3.rb>',
          'GOOD VERSION',
        ].join("\n")

        # src/2.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'OK: 2.rb',
        ].join("\n")

        # src/3.rb
        File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/3.rb", [
          'OK: 3.rb',
        ].join("\n")
      end # prepare new-my-repo#0.0.2

      before do
        find_repo_mock
      end

      context "use my-repo" do

        let(:input) do
          [
            '@snip<my-repo:1.rb>',
          ].join("\n")
        end

        let(:output) do
          [
            '@snippet<my-repo#1.0.0:2.rb>',
            'THIS_IS_OK',
            '@snippet<my-repo#1.0.0:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
          ].join("\n")
        end

        subject { instance.insert_snippet input }
        it { should eq output }

      end # use my-repo

      context "use my-repo#1" do

        let(:input) do
          [
            '@snip<my-repo#1:1.rb>',
          ].join("\n")
        end

        let(:output) do
          [
            '@snippet<my-repo#1.0.0:2.rb>',
            'THIS_IS_OK',
            '@snippet<my-repo#1.0.0:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
          ].join("\n")
        end

        subject { instance.insert_snippet input }
        it { should eq output }

      end # use my-repo#1

      context "use my-repo#1 and my-repo#0" do

        let(:input) do
          [
            '@snip<my-repo#1:1.rb>',
            '@snip<my-repo#0:1.rb>',
          ].join("\n")
        end

        let(:output) do
          [
            '@snippet<my-repo#1.0.0:2.rb>',
            'THIS_IS_OK',
            '@snippet<my-repo#1.0.0:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
            '@snippet<my-repo#0.0.3:2.rb>',
            '0.0.3',
            '@snippet<my-repo#0.0.3:1.rb>',
            'OK',
          ].join("\n")
        end

        subject { instance.insert_snippet input }
        it { should eq output }

      end # use my-repo#1 and my-repo#0

      context "use new-my-repo" do

        let(:input) do
          [
            '# @snip <new-my-repo:1.rb>',
          ].join("\n")
        end

        let(:output) do
          [
            '# @snippet <my-repo#0.0.3:2.rb>',
            '0.0.3',
            '# @snippet <my-repo#0.0.3:1.rb>',
            'OK',
            '# @snippet <new-my-repo#0.0.2:2.rb>',
            'OK: 2.rb',
            '# @snippet <new-my-repo#0.0.2:3.rb>',
            'OK: 3.rb',
            '# @snippet <new-my-repo#0.0.2:1.rb>',
            'GOOD VERSION',
          ].join("\n")
        end

        subject { instance.insert_snippet input }
        it { should eq output }

      end # use new-my-repo

    end # use multiple repos and multiple versions

    context "use latest version without ref" do

      before do
        repo_name = "my-repo"
        ref_name = "0.0.3"

        FileUtils.mkdir_p "#{repo_path}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/src"
        FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
        FileUtils.touch   "#{repo_path}/#{repo_name}/src/1.rb"
        FileUtils.touch   "#{repo_path}/#{repo_name}/src/2.rb"

        # snippet.json
        File.write "#{repo_path}/#{repo_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{repo_path}/#{repo_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "#{repo_path}/#{repo_name}/src/2.rb", [
          'def func_2',
          '  return 42',
          'end',
        ].join("\n")

      end # prepare my-repo#0.0.3

      before do
        allow_any_instance_of(SocialSnippet::Repository::GitRepository).to(
          receive(:get_refs).and_return([
            '0.0.1',
            '0.0.2',
            '0.0.3',
          ])
        )
        allow_any_instance_of(SocialSnippet::Repository::GitRepository).to(
          receive(:get_commit_id).and_return "#{commit_id}"
        )
        # must use latest version
        allow_any_instance_of(SocialSnippet::Repository::GitRepository).to(
          receive(:checkout).with("0.0.3").and_return true
        )
      end # prepare my-repo

      let(:input) do
        [
          '#@snip <my-repo:1.rb>',
        ].join("\n")
      end

      let(:output) do
        [
          '#@snippet <my-repo#0.0.3:2.rb>',
          'def func_2',
          '  return 42',
          'end',
          '#@snippet <my-repo#0.0.3:1.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")
      end

      subject { instance.insert_snippet input }
      it { should eq output }

    end # use latest version without ref

    context "snippet snippet with ref" do

      before do
        repo_name = "my-repo"
        ref_name = "0.0.1"

        FileUtils.mkdir_p "#{repo_path}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "#{repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "#{repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "#{repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'def func_2',
          '  return 42',
          'end',
        ].join("\n")

        allow(repo_manager).to receive(:find_repository).with(repo_name, ref_name) do
          repo = SocialSnippet::Repository::GitRepository.new("#{repo_path}/#{repo_name}/#{ref_name}")
          allow(repo).to receive(:get_refs).and_return([
            '0.0.1',
            '0.0.2',
          ])
          allow(repo).to receive(:get_commit_id).and_return "#{ref_name}#{commit_id}"
          repo.load_snippet_json
          repo.create_cache repo_cache_path
          repo
        end

      end # prepare my-repo#0.0.1

      before do
        repo_name = "my-repo"
        ref_name = "0.0.2"

        FileUtils.mkdir_p "#{repo_path}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "#{repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "#{repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "#{repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "#{repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "#{repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'def func_2',
          '  return 10000 + 42',
          'end',
        ].join("\n")

        allow(repo_manager).to receive(:find_repository).with(repo_name, ref_name) do
          repo = SocialSnippet::Repository::GitRepository.new("#{repo_path}/#{repo_name}/#{ref_name}")
          allow(repo).to receive(:get_refs).and_return([
            '0.0.1',
            '0.0.2',
          ])
          allow(repo).to receive(:get_commit_id).and_return "#{ref_name}#{commit_id}"
          repo.load_snippet_json
          repo.create_cache repo_cache_path
          repo
        end
      end # prepare my-repo#0.0.2

      context "use 0.0.1" do

        let(:input) do
          [
            '# main.rb',
            '# @snip <my-repo#0.0.1:1.rb>',
            'puts func_1',
          ].join("\n")
        end

        let(:output) do
          [
            '# main.rb',
            '# @snippet <my-repo#0.0.1:2.rb>',
            'def func_2',
            '  return 42',
            'end',
            '# @snippet <my-repo#0.0.1:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
            'puts func_1',
          ].join("\n")
        end

        subject { instance.insert_snippet(input) }
        it { should eq output }

      end # use 0.0.1

      context "use 0.0.2" do

        let(:input) do
          [
            '# main.rb',
            '# @snip <my-repo#0.0.2:1.rb>',
            'puts func_1',
          ].join("\n")
        end

        let(:output) do
          [
            '# main.rb',
            '# @snippet <my-repo#0.0.2:2.rb>',
            'def func_2',
            '  return 10000 + 42',
            'end',
            '# @snippet <my-repo#0.0.2:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
            'puts func_1',
          ].join("\n")
        end

        subject { instance.insert_snippet(input) }
        it { should eq output }

      end # use 0.0.2

      context "use 0.0.1 and 0.0.2" do

        let(:input) do
          [
            '# main.rb',
            '# @snip <my-repo#0.0.2:1.rb>',
            '# @snip <my-repo#0.0.1:1.rb>',
          ].join("\n")
        end

        let(:output) do
          [
            '# main.rb',
            '# @snippet <my-repo#0.0.2:2.rb>',
            'def func_2',
            '  return 10000 + 42',
            'end',
            '# @snippet <my-repo#0.0.2:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
            '# @snippet <my-repo#0.0.1:2.rb>',
            'def func_2',
            '  return 42',
            'end',
            '# @snippet <my-repo#0.0.1:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
          ].join("\n")
        end

        subject { instance.insert_snippet(input) }
        it { should eq output }

      end # use 0.0.1 and 0.0.2

    end # snippet snippet with ref

    context "snippet snippet" do

      before do
        repo_name = "my-repo"

        FileUtils.mkdir_p "#{repo_path}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/src"
        FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
        FileUtils.touch   "#{repo_path}/#{repo_name}/src/1.rb"
        FileUtils.touch   "#{repo_path}/#{repo_name}/src/2.rb"

        # snippet.json
        File.write "#{repo_path}/#{repo_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "#{repo_path}/#{repo_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "#{repo_path}/#{repo_name}/src/2.rb", [
          'def func_2',
          '  return 42',
          'end',
        ].join("\n")

        repo_config = Proc.new do |path|
          repo = SocialSnippet::Repository::GitRepository.new("#{repo_path}/#{repo_name}")
          allow(repo).to receive(:get_commit_id).and_return commit_id
          allow(repo).to receive(:get_refs).and_return []
          repo.load_snippet_json
          repo.create_cache repo_cache_path
          repo
        end

        allow(repo_manager).to receive(:find_repository).with(repo_name) { repo_config.call }
        allow(repo_manager).to receive(:find_repository).with(repo_name, short_commit_id) { repo_config.call }

      end # prepare my-repo

      let(:input) do
        [
          '# main.rb',
          '# @snip <my-repo:1.rb>',
          'puts func_1',
        ].join("\n")
      end

      let(:output) do
        [
          '# main.rb',
          '# @snippet <my-repo#' + short_commit_id + ':2.rb>',
          'def func_2',
          '  return 42',
          'end',
          '# @snippet <my-repo#' + short_commit_id + ':1.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
          'puts func_1',
        ].join("\n")
      end

      subject { instance.insert_snippet(input) }
      it { should eq output }

    end

    context "snip with repo" do

      before do
        repo_name = "my-repo"

        FileUtils.mkdir_p "#{repo_path}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/a"
        FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
        FileUtils.touch   "#{repo_path}/#{repo_name}/a.rb"
        FileUtils.touch   "#{repo_path}/#{repo_name}/a/1.rb"
        FileUtils.touch   "#{repo_path}/#{repo_name}/a/2.rb"

        # snippet.json
        File.write "#{repo_path}/#{repo_name}/snippet.json", [
          '{"name": "' + repo_name + '"}',
        ].join("\n")

        # a.rb
        File.write "#{repo_path}/#{repo_name}/a.rb", [
          '# @snip <./a/1.rb>',
          '# @snip <./a/2.rb>',
        ].join("\n")

        # a/1.rb
        File.write "#{repo_path}/#{repo_name}/a/1.rb", [
          'puts "1"',
        ].join("\n")

        # a/2.rb
        File.write "#{repo_path}/#{repo_name}/a/2.rb", [
          'puts "2"',
        ].join("\n")

        repo_config = Proc.new do |path|
          repo = SocialSnippet::Repository::GitRepository.new("#{repo_path}/#{repo_name}")
          allow(repo).to receive(:get_commit_id).and_return commit_id
          allow(repo).to receive(:get_refs).and_return []
          repo.load_snippet_json
          repo.create_cache repo_cache_path
          repo
        end

        allow(repo_manager).to receive(:find_repository).with("my-repo") { repo_config.call }
        allow(repo_manager).to receive(:find_repository).with("my-repo", short_commit_id) { repo_config.call }
      end # my-repo

      let(:input) do
        [
          "# @snip<my-repo:a.rb>"
        ].join("\n")
      end

      let(:output) do
        [
          '# @snippet<my-repo#' + short_commit_id + ':a/1.rb>',
          'puts "1"',
          '# @snippet<my-repo#' + short_commit_id + ':a/2.rb>',
          'puts "2"',
          '# @snippet<my-repo#' + short_commit_id + ':a.rb>',
        ].join("\n")
      end

      subject { instance.insert_snippet(input) }
      it { should eq output }

    end # snip with repo

    context "multiple snippets without duplicates" do

      before do
        repo_name = "repo-a"

        FileUtils.mkdir_p "#{repo_path}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
        FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
        FileUtils.touch   "#{repo_path}/#{repo_name}/parent"
        FileUtils.touch   "#{repo_path}/#{repo_name}/child_1"
        FileUtils.touch   "#{repo_path}/#{repo_name}/child_2"
        FileUtils.touch   "#{repo_path}/#{repo_name}/child_3"

        # snippet.json
        File.write "#{repo_path}/#{repo_name}/snippet.json", [
          '{"name": "' + repo_name + '"}',
        ].join("\n")

        # parent
        File.write "#{repo_path}/#{repo_name}/parent", [
          '@snip<child_1>',
          '@snip<child_2>',
          '@snip<child_3>',
        ].join("\n")

        repo_config = Proc.new do |path|
          repo = SocialSnippet::Repository::GitRepository.new("#{repo_path}/#{repo_name}")
          allow(repo).to receive(:get_commit_id).and_return commit_id
          allow(repo).to receive(:get_refs).and_return []
          repo.load_snippet_json
          repo.create_cache repo_cache_path
          repo
        end

        allow(repo_manager).to receive(:find_repository).with(repo_name) { repo_config.call }
        allow(repo_manager).to receive(:find_repository).with(repo_name, short_commit_id) { repo_config.call }
      end # repo-a

      let(:input) do
        [
          '@snip <repo-a:parent>',
        ].join("\n")
      end

      let(:output) do
        [
          '@snippet <repo-a#' + short_commit_id + ':child_1>',
          '@snippet <repo-a#' + short_commit_id + ':child_2>',
          '@snippet <repo-a#' + short_commit_id + ':child_3>',
          '@snippet <repo-a#' + short_commit_id + ':parent>',
        ].join("\n")
      end

      subject { instance.insert_snippet(input) }
      it { should eq output }

    end # multiple snippets without duplicates

    context "multiple snippets with duplicates" do

      before do
        repo_name = "my_repo"

        FileUtils.mkdir_p "#{repo_path}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
        FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
        FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
        FileUtils.touch   "#{repo_path}/#{repo_name}/parent"
        FileUtils.touch   "#{repo_path}/#{repo_name}/child_1"
        FileUtils.touch   "#{repo_path}/#{repo_name}/child_2"
        FileUtils.touch   "#{repo_path}/#{repo_name}/child_3"

        # snippet.json
        File.write "#{repo_path}/#{repo_name}/snippet.json", [
          '{"name": "' + repo_name + '"}',
        ].join("\n")

        # parent
        File.write "#{repo_path}/#{repo_name}/parent", [
          '@snip<child_1>',
          '@snip<child_2>',
          '@snip<child_2>',
          '@snip<child_3>',
          '@snip<child_1>',
          '@snip<child_2>',
          '@snip<child_3>',
        ].join("\n")

        repo_config = Proc.new do |path|
          repo = SocialSnippet::Repository::GitRepository.new("#{repo_path}/#{repo_name}")
          allow(repo).to receive(:get_commit_id).and_return commit_id
          allow(repo).to receive(:get_refs).and_return []
          repo.load_snippet_json
          repo.create_cache repo_cache_path
          repo
        end

        allow(repo_manager).to receive(:find_repository).with(repo_name) { repo_config.call }
        allow(repo_manager).to receive(:find_repository).with(repo_name, short_commit_id) { repo_config.call }
      end

      let(:input) do
        [
          '@snip <my_repo:parent>',
          '@snip<my_repo:child_3>',
          '@snip<my_repo:child_2>',
          '@snip<my_repo:child_1>',
        ].join("\n")
      end

      let(:output) do
        [
          '@snippet <my_repo#' + short_commit_id + ':child_1>',
          '@snippet <my_repo#' + short_commit_id + ':child_2>',
          '@snippet <my_repo#' + short_commit_id + ':child_3>',
          '@snippet <my_repo#' + short_commit_id + ':parent>',
        ].join("\n")
      end

      subject { instance.insert_snippet(input) }
      it { should eq output }

    end

    context "more duplicate cases" do

      context "already snipped" do

        before do
          repo_name = "my-repo"

          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/.git"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/src"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/src/1"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/src/2"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/src/3"

          # snippet.json
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join("\n")

          # src/1
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/src/1", [
            '@snip<2>',
            '@snip<3>',
          ].join("\n")

          # src/2
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/src/2", [
            '2',
          ].join("\n")

          # src/3
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/src/3", [
            '3',
          ].join("\n")
        end # prepare for my-repo

        before do
          repo_name = "has-version"
          repo_version = "0.0.1"

          FileUtils.mkdir_p "#{tmp_repo_path}"
          FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
          FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}"
          FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}/.git"
          FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src"
          FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/snippet.json"
          FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/1"
          FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/2"
          FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/3"

          # snippet.json
          File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join("\n")

          # src/1
          File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/1", [
            '@snip<2>',
            '@snip<3>',
            '0.0.1: 1',
          ].join("\n")

          # src/2
          File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/2", [
            '0.0.1: 2',
          ].join("\n")

          # src/3
          File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/3", [
            '0.0.1: 3',
          ].join("\n")
        end # prepare has-version#0.0.1

        before do
          repo_name = "has-version"
          repo_version = "1.2.3"

          FileUtils.mkdir_p "#{tmp_repo_path}"
          FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
          FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}"
          FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}/.git"
          FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src"
          FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/snippet.json"
          FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/1"
          FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/2"
          FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/3"

          # snippet.json
          File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join("\n")

          # src/1
          File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/1", [
            '@snip<2>',
            '@snip<3>',
            '1.2.3: 1',
          ].join("\n")

          # src/2
          File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/2", [
            '1.2.3: 2',
          ].join("\n")

          # src/3
          File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/3", [
            '1.2.3: 3',
          ].join("\n")
        end # prepare has-version#1.2.3

        before do
          find_repo_mock
        end

        context "already snipped using version" do

          context "not already snipped" do

            let(:input) do
              [
                '@snip<has-version#0:1>',
                '@snip<has-version#1:1>',
              ].join("\n").freeze
            end

            let(:output) do
              [
                '@snippet<has-version#0.0.1:2>',
                '0.0.1: 2',
                '@snippet<has-version#0.0.1:3>',
                '0.0.1: 3',
                '@snippet<has-version#0.0.1:1>',
                '0.0.1: 1',
                '@snippet<has-version#1.2.3:2>',
                '1.2.3: 2',
                '@snippet<has-version#1.2.3:3>',
                '1.2.3: 3',
                '@snippet<has-version#1.2.3:1>',
                '1.2.3: 1',
              ].join("\n").freeze
            end

            subject { instance.insert_snippet(input) }
            it { should eq output }

          end

          context "snipped", :force => true do

            let(:input) do
              [
                '@snippet<has-version#0.0.1:1>',
                '@snip<has-version#0:1>',
                '@snip<has-version#1:1>',
              ].join("\n").freeze
            end

            let(:output) do
              [
                '@snippet<has-version#0.0.1:1>',
                '@snippet<has-version#1.2.3:2>',
                '1.2.3: 2',
                '@snippet<has-version#1.2.3:3>',
                '1.2.3: 3',
                '@snippet<has-version#1.2.3:1>',
                '1.2.3: 1',
              ].join("\n").freeze
            end

            subject { instance.insert_snippet(input) }
            it { should eq output }

          end # snipped

          context "use another repo" do

            let(:input) do
              [
                '@snippet<has-version#0.0.1:1>',
                '@snip<has-version#0:1>',
                '@snip<my-repo:1>',
                '@snip<has-version:1>',
              ].join("\n").freeze
            end

            let(:output) do
              [
                '@snippet<has-version#0.0.1:1>',
                '@snippet<my-repo#thisisdu:2>',
                '2',
                '@snippet<my-repo#thisisdu:3>',
                '3',
                '@snippet<my-repo#thisisdu:1>',
                '@snippet<has-version#1.2.3:2>',
                '1.2.3: 2',
                '@snippet<has-version#1.2.3:3>',
                '1.2.3: 3',
                '@snippet<has-version#1.2.3:1>',
                '1.2.3: 1',
              ].join("\n").freeze
            end

            subject { instance.insert_snippet(input) }
            it { should eq output }

          end

        end # already snipped using version

        context "already snipped case" do

          let(:input) do
            [
              '@snippet<my-repo#' + short_commit_id + ':3>',
              '3',
              '',
              '@snip<my-repo:1>',
              '@snip<my-repo:2>',
            ].join("\n")
          end

          let(:output) do
            [
              '@snippet<my-repo#' + short_commit_id + ':3>',
              '3',
              '',
              '@snippet<my-repo#' + short_commit_id + ':2>',
              '2',
              '@snippet<my-repo#' + short_commit_id + ':1>',
            ].join("\n")
          end

          subject { instance.insert_snippet(input) }
          it { should eq output }

        end # already snipped case

        context "not already snipped case" do

          let(:input) do
            [
              '@snip<my-repo:1>',
              '@snip<my-repo:2>',
              '@snip<my-repo:3>',
            ].join("\n")
          end

          let(:output) do
            [
              '@snippet<my-repo#' + short_commit_id + ':2>',
              '2',
              '@snippet<my-repo#' + short_commit_id + ':3>',
              '3',
              '@snippet<my-repo#' + short_commit_id + ':1>',
            ].join("\n")
          end

          subject { instance.insert_snippet(input) }
          it { should eq output }

        end # not already snipped case

      end # alread snipped

      context "other repos have same snip tag" do

        before do
          repo_name = "my_lib"

          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/.git"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/src/lib"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/src/lib/add_func.cpp"

          # snippet.json
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join("\n")

          # src/add_func.cpp
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/src/add_func.cpp", [
            'int add_func( int a, int b ) {',
            '  return a + b;',
            '}',
          ].join("\n")
        end # prepare for my_lib repo

        before do
          repo_name = "my_repo_a"

          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/.git"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/use_add_func.cpp"

          # snippet.json
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json", [
            '{"name": "' + repo_name + '"}',
          ].join("\n")

          # use_add_func.cpp
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/use_add_func.cpp", [
            '// @snip <my_lib:add_func.cpp>',
            'int my_repo_a_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
          ].join("\n")
        end # prepare for my_repo_a repo

        before do
          repo_name = "my_repo_b"

          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}"
          FileUtils.mkdir_p "#{tmp_repo_path_no_ver}/#{repo_name}/.git"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json"
          FileUtils.touch   "#{tmp_repo_path_no_ver}/#{repo_name}/use_add_func.cpp"

          # snippet.json
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/snippet.json", [
            '{"name": "' + repo_name + '"}',
          ].join("\n")

          # use_add_func.cpp
          File.write "#{tmp_repo_path_no_ver}/#{repo_name}/use_add_func.cpp", [
            '// @snip <my_lib:add_func.cpp>',
            'int my_repo_b_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
          ].join("\n")
        end # prepare for my_repo_b repo

        before { find_repo_mock }

        let(:input) do
          [
            '#include <iostream>',
            '',
            '// @snip<my_repo_a:use_add_func.cpp>',
            '// @snip<my_repo_b:use_add_func.cpp>',
            '',
            'int main() {',
            '  int a, b;',
            '  std::cin >> a >> b;',
            '  std::cout << my_repo_a_use_add_func(a, b) << " == " << my_repo_a_use_add_func(a, b) << std::endl;',
            '  return 0;',
            '}',
          ].join("\n")
        end

        let(:output) do
          [
            '#include <iostream>',
            '',
            '// @snippet<my_lib#' + short_commit_id + ':add_func.cpp>',
            'int add_func( int a, int b ) {',
            '  return a + b;',
            '}',
            '// @snippet<my_repo_a#' + short_commit_id + ':use_add_func.cpp>',
            'int my_repo_a_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
            '// @snippet<my_repo_b#' + short_commit_id + ':use_add_func.cpp>',
            'int my_repo_b_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
            '',
            'int main() {',
            '  int a, b;',
            '  std::cin >> a >> b;',
            '  std::cout << my_repo_a_use_add_func(a, b) << " == " << my_repo_a_use_add_func(a, b) << std::endl;',
            '  return 0;',
            '}',
          ].join("\n")
        end

        context "call insert_snippet" do
          subject { instance.insert_snippet(input) }
          it { should eq output }
        end

      end # other repos have same snip tags

    end # more duplicate cases

  end # insert_snippet

end # SocialSnippet::SocialSnippet
