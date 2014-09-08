require "spec_helper"

describe SocialSnippet::SocialSnippet do

  # Enable FakeFS
  before { FakeFS.activate! }
  after { FakeFS.deactivate!; FakeFS::FileSystem.clear }

  let(:instance) { SocialSnippet::SocialSnippet.new }
  let(:repo_manager) { SocialSnippet::RepositoryManager.new(SocialSnippet::Config.new) }
  let(:repo_path) { "#{ENV["HOME"]}/.social-snippet/repo" }
  let(:repo_cache_path) { "#{ENV["HOME"]}/.social-snippet/repo_cache" }
  let(:commit_id) { "thisisdummy" }
  let(:short_commit_id) { commit_id[0..7] }

  before { allow(instance).to receive(:repo_manager).and_return repo_manager }

  describe "#insert_snippet" do

    context "use multiple repos and multiple versions" do

      before do
        repo_name = "my-repo"
        ref_name = "0.0.3"

        FileUtils.mkdir_p "/tmp/repos/#{repo_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'OK',
        ].join("\n")

        # src/2.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb", [
          '0.0.3',
        ].join("\n")

      end # prepare my-repo#0.0.3

      before do
        repo_name = "my-repo"
        ref_name = "0.0.2"

        FileUtils.mkdir_p "/tmp/repos/#{repo_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb", [
          'ERROR_CASE',
        ].join("\n")

      end # prepare my-repo#0.0.2

      before do
        repo_name = "my-repo"
        ref_name = "0.0.1"

        FileUtils.mkdir_p "/tmp/repos/#{repo_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb", [
          'ERROR_CASE',
        ].join("\n")

      end # prepare my-repo#0.0.1

      before do
        repo_name = "my-repo"
        ref_name = "1.0.0"

        FileUtils.mkdir_p "/tmp/repos/#{repo_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join("\n")

        # src/2.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb", [
          'THIS_IS_OK',
        ].join("\n")
      end # prepare my-repo#1.0.0

      before do
        repo_name = "new-my-repo"
        ref_name = "0.0.1"

        FileUtils.mkdir_p "/tmp/repos/#{repo_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb"

        # snippet.json
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb", [
          'OLD VERSION',
        ].join("\n")
      end # prepare new-my-repo#0.0.1

      before do
        repo_name = "new-my-repo"
        ref_name = "0.0.2"

        FileUtils.mkdir_p "/tmp/repos/#{repo_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/.git"
        FileUtils.mkdir_p "/tmp/repos/#{repo_name}/#{ref_name}/src"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb"
        FileUtils.touch   "/tmp/repos/#{repo_name}/#{ref_name}/src/3.rb"

        # snippet.json
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join("\n")

        # src/1.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip <my-repo#0:1.rb>',
          '# @snip </2.rb>',
          '# @snip <3.rb>',
          'GOOD VERSION',
        ].join("\n")

        # src/2.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/2.rb", [
          'OK: 2.rb',
        ].join("\n")

        # src/3.rb
        File.write "/tmp/repos/#{repo_name}/#{ref_name}/src/3.rb", [
          'OK: 3.rb',
        ].join("\n")
      end # prepare new-my-repo#0.0.2

      before do
        repo_versions = {}
        repos = Dir.glob("/tmp/repos/*").map{|path| Pathname.new(path).basename.to_s }
        repos.each do |repo_name|
          repo_versions[repo_name] = Dir.glob("/tmp/repos/#{repo_name}/*").map {|path| Pathname.new(path).basename.to_s }
        end

        allow(repo_manager).to receive(:find_repository).with(any_args) do |repo_name, ref|
          base_repo_path = "/tmp/repos/#{repo_name}/#{repo_versions[repo_name].first}"
          base_repo = SocialSnippet::Repository::GitRepository.new(base_repo_path)
          allow(base_repo).to receive(:get_refs).and_return repo_versions[repo_name]
          base_repo.load_snippet_json

          repo_version = base_repo.get_latest_version ref
          repo_path = "/tmp/repos/#{repo_name}/#{repo_version}"
          repo = SocialSnippet::Repository::GitRepository.new(repo_path)
          allow(repo).to receive(:get_refs).and_return repo_versions[repo_name]
          allow(repo).to receive(:get_commit_id).and_return "#{repo_version}#{commit_id}"
          repo.load_snippet_json
          repo.create_cache repo_cache_path
          repo
        end
      end # find_repo mock

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

          FileUtils.mkdir_p "#{repo_path}"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}/src"
          FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
          FileUtils.touch   "#{repo_path}/#{repo_name}/src/1"
          FileUtils.touch   "#{repo_path}/#{repo_name}/src/2"
          FileUtils.touch   "#{repo_path}/#{repo_name}/src/3"

          # snippet.json
          File.write "#{repo_path}/#{repo_name}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join("\n")

          # src/1
          File.write "#{repo_path}/#{repo_name}/src/1", [
            '@snip<2>',
            '@snip<3>',
          ].join("\n")

          # src/2
          File.write "#{repo_path}/#{repo_name}/src/2", [
            '2',
          ].join("\n")

          # src/3
          File.write "#{repo_path}/#{repo_name}/src/3", [
            '3',
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
        end # prepare for my-repo

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

          FileUtils.mkdir_p "#{repo_path}"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}/src/lib"
          FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
          FileUtils.touch   "#{repo_path}/#{repo_name}/src/lib/add_func.cpp"

          # snippet.json
          File.write "#{repo_path}/#{repo_name}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join("\n")

          # src/add_func.cpp
          File.write "#{repo_path}/#{repo_name}/src/add_func.cpp", [
            'int add_func( int a, int b ) {',
            '  return a + b;',
            '}',
          ].join("\n")

          repo_config = Proc.new do |path|
            repo = SocialSnippet::Repository::GitRepository.new("#{repo_path}/#{repo_name}")
            allow(repo).to receive(:get_commit_id).and_return commit_id
            allow(repo).to receive(:get_refs).and_return []
            repo.load_snippet_json
            repo.create_cache repo_cache_path
            repo
          end

          allow(repo_manager).to receive(:find_repository).with(repo_name).and_return repo_config.call
          allow(repo_manager).to receive(:find_repository).with(repo_name, short_commit_id).and_return repo_config.call
        end # prepare for my_lib repo

        before do
          repo_name = "my_repo_a"

          FileUtils.mkdir_p "#{repo_path}"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
          FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
          FileUtils.touch   "#{repo_path}/#{repo_name}/use_add_func.cpp"

          # snippet.json
          File.write "#{repo_path}/#{repo_name}/snippet.json", [
            '{"name": "' + repo_name + '"}',
          ].join("\n")

          # use_add_func.cpp
          File.write "#{repo_path}/#{repo_name}/use_add_func.cpp", [
            '// @snip <my_lib:add_func.cpp>',
            'int my_repo_a_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
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
        end # prepare for my_repo_a repo

        before do
          repo_name = "my_repo_b"

          FileUtils.mkdir_p "#{repo_path}"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}"
          FileUtils.mkdir_p "#{repo_path}/#{repo_name}/.git"
          FileUtils.touch   "#{repo_path}/#{repo_name}/snippet.json"
          FileUtils.touch   "#{repo_path}/#{repo_name}/use_add_func.cpp"

          # snippet.json
          File.write "#{repo_path}/#{repo_name}/snippet.json", [
            '{"name": "' + repo_name + '"}',
          ].join("\n")

          # use_add_func.cpp
          File.write "#{repo_path}/#{repo_name}/use_add_func.cpp", [
            '// @snip <my_lib:add_func.cpp>',
            'int my_repo_b_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
          ].join("\n")

          repo_config = Proc.new do |path|
            repo = SocialSnippet::Repository::GitRepository.new("#{repo_path}/#{repo_name}")
            allow(repo).to receive(:get_commit_id).and_return commit_id
            allow(repo).to receive(:get_refs).and_return []
            repo.load_snippet_json
            repo.create_cache repo_cache_path
            repo
          end

          allow(repo_manager).to receive(:find_repository).with(repo_name).and_return repo_config.call
          allow(repo_manager).to receive(:find_repository).with(repo_name, short_commit_id).and_return repo_config.call
        end # prepare for my_repo_b repo

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
