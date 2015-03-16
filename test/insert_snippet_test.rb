require "spec_helper"

describe SocialSnippet::Api::InsertSnippetApi do

  let(:tmp_repo_path) { "/tmp/repos" }
  let(:repo_cache_path) { fake_config.repository_cache_path }

  #
  # Helpers
  #
  def reload_tmp_repos
    ::Dir.glob(::File.join tmp_repo_path, "*") do |s|
      repo_name = ::File.basename(s)
      repo = ::SocialSnippet::Repository::Models::Repository.find_or_create_by(
        :name => repo_name,
      )
      add_tmp_repo_refs repo_name, repo
    end
  end

  def add_tmp_repo_refs(repo_name, repo)
    ::Dir.glob(::File.join tmp_repo_path, repo_name, "*") do |s|
      next unless ::File.directory?(s)
      repo_ref = ::File.basename(s)
      repo.add_ref repo_ref, "rev-#{repo_ref}"
      repo.update_attributes! :current_ref => repo_ref if repo.current_ref.nil?
      repo.add_package repo_ref
      pkg = ::SocialSnippet::Repository::Models::Package.find_or_create_by(
        :repo_name => repo_name,
        :rev_hash => "rev-#{repo_ref}",
      )
      repo_dirpath = ::File.join(tmp_repo_path, repo_name, repo_ref)
      add_tmp_repo_files(repo_dirpath, pkg)
    end
  end

  def add_tmp_repo_files(repo_dirpath, pkg)
    ::Dir.glob(::File.join repo_dirpath, "**", "*") do |s|
      next unless ::File.file?(s)
      filepath = s[repo_dirpath.length..-1]
      pkg.add_directory ::File.dirname(filepath)
      pkg.add_file filepath, ::File.read(s)
    end
  end

  def self.prepare_repository(&block)
    before do
      instance_eval &block
      reload_tmp_repos
    end
  end

  describe "#insert_snippet" do

    context "use commit id" do

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "thisisdu"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/file.c"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/file.c", [
          '/* file.c */'
        ].join($/)
      end # prepare my-repo#thisisdu

      context "snip my-repo#thisisdu" do

        let(:input) do
          [
            '/* main.c */',
            '@snip<my-repo#thisisdu:file.c>',
          ].join($/)
        end

        let(:output) do
          [
            '/* main.c */',
            '@snippet<my-repo#thisisdu:file.c>',
            '/* file.c */',
          ].join($/)
        end

        subject { fake_core.api.insert_snippet input }
        it { should eq output }

      end # snip my-repo#thisisdu

      context "snip my-repo#notexist" do

        let(:input) do
          [
            '/* main.c */',
            '@snip<my-repo#notexist:file.c>',
          ].join($/)
        end

        subject do
          lambda { fake_core.api.insert_snippet input }
        end

        it { should raise_error }

      end # snip my-repo#thisisdu

    end # use commid id

    context "version up" do

      context "snip my-repo#1" do

        let(:input) do
          [
            '/* @snip<my-repo#1:func.c> */',
            'main',
          ].join($/)
        end

        context "release 1.0.0" do

          prepare_repository do
            repo_name = "my-repo"
            ref_name = "1.0.0"

            ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
            ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
            ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
            ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/func.c"

            # snippet.json
            ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
              '{"name": "' + repo_name + '"}'
            ].join($/)

            ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/func.c", [
              'func: 1.0.0',
            ].join($/)
          end # prepare my-repo#1.0.0

          let(:output) do
            [
              '/* @snippet<my-repo#1.0.0:func.c> */',
              'func: 1.0.0',
              'main',
            ].join($/)
          end

          subject { fake_core.api.insert_snippet(input) }
          it { should eq output }

          context "release 1.0.1" do

            prepare_repository do
              repo_name = "my-repo"
              ref_name = "1.0.1"

              ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
              ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
              ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
              ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/func.c"

              # snippet.json
              ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
                '{"name": "' + repo_name + '"}'
              ].join($/)

              ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/func.c", [
                'func: 1.0.1',
              ].join($/)
            end # prepare my-repo#1.0.1

            let(:output) do
              [
                '/* @snippet<my-repo#1.0.1:func.c> */',
                'func: 1.0.1',
                'main',
              ].join($/)
            end

            subject { fake_core.api.insert_snippet(input) }
            it { should eq output }

            context "release 1.1.0" do

              prepare_repository do
                repo_name = "my-repo"
                ref_name = "1.1.0"

                ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
                ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
                ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
                ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/func.c"

                # snippet.json
                ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
                  '{"name": "' + repo_name + '"}'
                ].join($/)

                ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/func.c", [
                  'func: 1.1.0',
                ].join($/)
              end # prepare my-repo#1.1.0

              it do
                expect(fake_core.api.insert_snippet(input)).to eq [
                  '/* @snippet<my-repo#1.1.0:func.c> */',
                  'func: 1.1.0',
                  'main',
                ].join($/).freeze
              end

              context "release 9.9.9" do

                prepare_repository do
                  repo_name = "my-repo"
                  ref_name = "9.9.9"

                  ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
                  ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
                  ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
                  ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/func.c"

                  # snippet.json
                  ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
                    '{"name": "' + repo_name + '"}'
                  ].join($/)

                  ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/func.c", [
                    'func: 9.9.9',
                  ].join($/)
                end # prepare my-repo#9.9.9

                it do
                  expect(fake_core.api.insert_snippet(input)).to eq [
                    '/* @snippet<my-repo#1.1.0:func.c> */',
                    'func: 1.1.0',
                    'main',
                  ].join($/).freeze
                end

              end # release 9.9.9

            end # release 1.1.0

          end # release 1.0.1

        end # release 1.0.0

      end # snip my-repo#1

    end # version up

    context "use parent path" do

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "1.2.3"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/file_1"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_a"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_a/file_2"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_b"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_b/file_3"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_c"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_c/file_4"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/file_1", [
          '@snip<subdir_a/file_2>',
          'file_1',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_a/file_2", [
          '@snip<../subdir_b/file_3>',
          'file_2',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_b/file_3", [
          '@snip<../subdir_c/file_4>',
          'file_3',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/subdir_c/file_4", [
          'file_4',
        ].join($/)
      end # prepare my-repo#1.2.3

      context "snip my-repo:file_1" do

        let(:input) do
          [
            '@snip <my-repo:file_1>',
            'main',
          ].join($/).freeze
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
          ].join($/).freeze
        end

        subject { fake_core.api.insert_snippet input }
        it { should eq output }

      end

    end # use parent path

    context "snip self" do

      prepare_repository do
        repo_name = "directly"
        ref_name = "3.2.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1", [
          '@snip<1>',
          '1',
        ].join($/)
      end # prepare directly#3.2.1

      prepare_repository do
        repo_name = "loop-1"
        ref_name = "1.1.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop", [
          '@snip<loop-2:loop>',
          'loop-1',
        ].join($/)
      end # prepare loop-1#1.1.1

      prepare_repository do
        repo_name = "loop-2"
        ref_name = "1.1.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop", [
          '@snip<loop-3:loop>',
          'loop-2',
        ].join($/)
      end # prepare loop-2#1.1.1

      prepare_repository do
        repo_name = "loop-3"
        ref_name = "1.1.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/loop", [
          '@snip<loop-1:loop>',
          '@snip<non-loop-4:non-loop>',
          'loop-3',
        ].join($/)
      end # prepare loop-3#1.1.1

      prepare_repository do
        repo_name = "non-loop-4"
        ref_name = "1.1.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/non-loop"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/non-loop", [
          'non-loop-4',
        ].join($/)
      end # prepare non-loop-4#1.1.1

      context "indirectly" do

        context "has cyclic loop" do

          let(:input) do
            [
              '@snip<loop-1:loop>',
              'main',
            ].join($/)
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
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end # has loop

      end # indirectly

      context "directly" do

        context "snip directly:1" do

          let(:input) do
            [
              '@snip<directly:1>',
            ].join($/).freeze
          end

          let(:output) do
            [
              '@snippet<directly#3.2.1:1>',
              '1',
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end

      end # directly

    end # snip self

    context "snippet snippet ... snippet" do

      prepare_repository do
        repo_name = "my-repo-1"
        ref_name = "0.0.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1", [
          '@snip<my-repo-2#0:2>',
          'my-repo-1:1',
        ].join($/)
      end # prepare my-repo-1

      prepare_repository do
        repo_name = "my-repo-2"
        ref_name = "0.0.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2", [
          '@snip<my-repo-3:path/to/3>',
          'my-repo-2:2',
        ].join($/)
      end # prepare my-repo-2#0.0.1

      prepare_repository do
        repo_name = "my-repo-2"
        ref_name = "1.2.3"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2", [
          'miss!!',
        ].join($/)
      end # prepare my-repo-2#1.2.3

      prepare_repository do
        repo_name = "my-repo-3"
        ref_name = "1.2.3"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/path"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/path/to"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/path/to/3"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/path/to/3", [
          '@snip<my-repo-4:path/to/4>',
          'my-repo-3:path/to/3',
        ].join($/)
      end # prepare my-repo-3#1.2.3

      prepare_repository do
        repo_name = "my-repo-4"
        ref_name = "1.2.3"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/4"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/4", [
          '@snip<my-repo-5:path/to/5>',
          'my-repo-4:sources/path/to/4',
        ].join($/)
      end # prepare my-repo-4#1.2.3

      prepare_repository do
        repo_name = "my-repo-5"
        ref_name = "100.200.300"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/5"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/5", [
          '@snip<my-repo-6:path/to/6>',
          'my-repo-5:sources/path/to/5',
        ].join($/)
      end # prepare my-repo-5#100.200.300

      prepare_repository do
        repo_name = "my-repo-5"
        ref_name = "99.999.999"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/5"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/5", [
          'miss!!',
          'my-repo-5:5',
        ].join($/)
      end # prepare my-repo-5#99.999.999

      prepare_repository do
        repo_name = "my-repo-6"
        ref_name = "master"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/6"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/6", [
          '@snip<my-repo-7:path/to/7>',
          'my-repo-6:sources/path/to/6',
        ].join($/)
      end # prepare my-repo-6

      before do
        repo = ::SocialSnippet::Repository::Models::Repository.find_by(:name => "my-repo-6")
        repo.update_attributes! :current_ref => "master"
      end

      prepare_repository do
        repo_name = "my-repo-7"
        ref_name = "1.2.3"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/7"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "sources"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/sources/path/to/7", [
          'end',
          'my-repo-7:sources/path/to/7',
        ].join($/)
      end # prepare my-repo-7#1.2.3

      context "snip my-repo-1:1" do

        let(:input) do
          [
            '/* @snip <my-repo-1:1> */',
          ].join($/).freeze
        end

        let(:output) do
          [
            '/* @snippet <my-repo-7#1.2.3:path/to/7> */',
            'end',
            'my-repo-7:sources/path/to/7',
            '/* @snippet <my-repo-6#master:path/to/6> */',
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
          ].join($/).freeze
        end

        subject { fake_core.api.insert_snippet input }
        it { should eq output }

      end # snip my-repo-1:1

    end # snippet snippet ... snippet

    context "snippet snippets" do

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "0.0.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/3"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/4"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/5"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/6"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/7"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/8"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/9"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}'
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/1", [
          '@snip<5>',
          '@snip<4>',
          '@snip<3>',
          '@snip<2>',
          '1',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/2", [
          '@snip<9>',
          '@snip<8>',
          '@snip<7>',
          '@snip<6>',
          '2',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/3", [
          '3',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/4", [
          '4',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/5", [
          '5',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/6", [
          '6',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/7", [
          '7',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/8", [
          '8',
        ].join($/)

        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/9", [
          '9',
        ].join($/)
      end

      let(:input) do
        [
          '@snip<my-repo:1>',
          'main',
        ].join($/).freeze
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
        ].join($/)
      end

      subject { fake_core.api.insert_snippet input }
      it { should eq output }

    end # snippet snippets

    context "use multiple repos and multiple versions" do

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "0.0.3"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'OK',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          '0.0.3',
        ].join($/)

      end # prepare my-repo#0.0.3

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "0.0.2"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'ERROR_CASE',
        ].join($/)

      end # prepare my-repo#0.0.2

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "0.0.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'ERROR_CASE',
        ].join($/)

      end # prepare my-repo#0.0.1

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "1.0.0"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'THIS_IS_OK',
        ].join($/)
      end # prepare my-repo#1.0.0

      prepare_repository do
        repo_name = "new-my-repo"
        ref_name = "0.0.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          'OLD VERSION',
        ].join($/)
      end # prepare new-my-repo#0.0.1

      prepare_repository do
        repo_name = "new-my-repo"
        ref_name = "0.0.2"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/3.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip <my-repo#0:1.rb>',
          '# @snip </2.rb>',
          '# @snip <3.rb>',
          'GOOD VERSION',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'OK: 2.rb',
        ].join($/)

        # src/3.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/3.rb", [
          'OK: 3.rb',
        ].join($/)
      end # prepare new-my-repo#0.0.2

      context "use my-repo" do

        let(:input) do
          [
            '@snip<my-repo:1.rb>',
          ].join($/)
        end

        let(:output) do
          [
            '@snippet<my-repo#1.0.0:2.rb>',
            'THIS_IS_OK',
            '@snippet<my-repo#1.0.0:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
          ].join($/)
        end

        subject { fake_core.api.insert_snippet input }
        it { should eq output }

      end # use my-repo

      context "use my-repo#1" do

        let(:input) do
          [
            '@snip<my-repo#1:1.rb>',
          ].join($/)
        end

        let(:output) do
          [
            '@snippet<my-repo#1.0.0:2.rb>',
            'THIS_IS_OK',
            '@snippet<my-repo#1.0.0:1.rb>',
            'def func_1',
            '  return 2 * func_2()',
            'end',
          ].join($/)
        end

        subject { fake_core.api.insert_snippet input }
        it { should eq output }

      end # use my-repo#1

      context "use my-repo#1 and my-repo#0" do

        let(:input) do
          [
            '@snip<my-repo#1:1.rb>',
            '@snip<my-repo#0:1.rb>',
          ].join($/)
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
          ].join($/)
        end

        subject { fake_core.api.insert_snippet input }
        it { should eq output }

      end # use my-repo#1 and my-repo#0

      context "use new-my-repo" do

        let(:input) do
          [
            '# @snip <new-my-repo:1.rb>',
          ].join($/)
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
          ].join($/)
        end

        subject { fake_core.api.insert_snippet input }
        it { should eq output }

      end # use new-my-repo

    end # use multiple repos and multiple versions

    context "use latest version without ref" do

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "0.0.3"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'def func_2',
          '  return 42',
          'end',
        ].join($/)

      end # prepare my-repo#0.0.3

      let(:input) do
        [
          '#@snip <my-repo:1.rb>',
        ].join($/)
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
        ].join($/)
      end

      subject { fake_core.api.insert_snippet input }
      it { should eq output }

    end # use latest version without ref

    context "snippet snippet with ref" do

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "0.0.1"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'def func_2',
          '  return 42',
          'end',
        ].join($/)

      end # prepare my-repo#0.0.1

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "0.0.2"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'def func_2',
          '  return 10000 + 42',
          'end',
        ].join($/)

      end # prepare my-repo#0.0.2

      context "use 0.0.1" do

        let(:input) do
          [
            '# main.rb',
            '# @snip <my-repo#0.0.1:1.rb>',
            'puts func_1',
          ].join($/)
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
          ].join($/)
        end

        subject { fake_core.api.insert_snippet(input) }
        it { should eq output }

      end # use 0.0.1

      context "use 0.0.2" do

        let(:input) do
          [
            '# main.rb',
            '# @snip <my-repo#0.0.2:1.rb>',
            'puts func_1',
          ].join($/)
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
          ].join($/)
        end

        subject { fake_core.api.insert_snippet(input) }
        it { should eq output }

      end # use 0.0.2

      context "use 0.0.1 and 0.0.2" do

        let(:input) do
          [
            '# main.rb',
            '# @snip <my-repo#0.0.2:1.rb>',
            '# @snip <my-repo#0.0.1:1.rb>',
          ].join($/)
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
          ].join($/)
        end

        subject { fake_core.api.insert_snippet(input) }
        it { should eq output }

      end # use 0.0.1 and 0.0.2

    end # snippet snippet with ref

    context "snippet snippet" do

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "master"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '", "main": "src"}',
        ].join($/)

        # src/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1.rb", [
          '# @snip</2.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
        ].join($/)

        # src/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2.rb", [
          'def func_2',
          '  return 42',
          'end',
        ].join($/)

      end # prepare my-repo

      let(:input) do
        [
          '# main.rb',
          '# @snip <my-repo:1.rb>',
          'puts func_1',
        ].join($/)
      end

      let(:output) do
        [
          '# main.rb',
          '# @snippet <my-repo#master:2.rb>',
          'def func_2',
          '  return 42',
          'end',
          '# @snippet <my-repo#master:1.rb>',
          'def func_1',
          '  return 2 * func_2()',
          'end',
          'puts func_1',
        ].join($/)
      end

      subject { fake_core.api.insert_snippet(input) }
      it { should eq output }

    end

    context "snip with repo" do

      prepare_repository do
        repo_name = "my-repo"
        ref_name = "master"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/a"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/a.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/a/1.rb"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/a/2.rb"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}',
        ].join($/)

        # a.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/a.rb", [
          '# @snip <./a/1.rb>',
          '# @snip <./a/2.rb>',
        ].join($/)

        # a/1.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/a/1.rb", [
          'puts "1"',
        ].join($/)

        # a/2.rb
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/a/2.rb", [
          'puts "2"',
        ].join($/)
      end # my-repo

      let(:input) do
        [
          "# @snip<my-repo:a.rb>"
        ].join($/)
      end

      let(:output) do
        [
          '# @snippet<my-repo#master:a/1.rb>',
          'puts "1"',
          '# @snippet<my-repo#master:a/2.rb>',
          'puts "2"',
          '# @snippet<my-repo#master:a.rb>',
        ].join($/)
      end

      subject { fake_core.api.insert_snippet(input) }
      it { should eq output }

    end # snip with repo

    context "multiple snippets without duplicates" do

      prepare_repository do
        repo_name = "repo-a"
        ref_name = "master"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/parent"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/child_1"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/child_2"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/child_3"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}',
        ].join($/)

        # parent
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/parent", [
          '@snip<child_1>',
          '@snip<child_2>',
          '@snip<child_3>',
        ].join($/)
      end # repo-a

      let(:input) do
        [
          '@snip <repo-a:parent>',
        ].join($/)
      end

      let(:output) do
        [
          '@snippet <repo-a#master:child_1>',
          '@snippet <repo-a#master:child_2>',
          '@snippet <repo-a#master:child_3>',
          '@snippet <repo-a#master:parent>',
        ].join($/)
      end

      subject { fake_core.api.insert_snippet(input) }
      it { should eq output }

    end # multiple snippets without duplicates

    context "multiple snippets with duplicates" do

      prepare_repository do
        repo_name = "my_repo"
        ref_name = "master"

        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
        ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/parent"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/child_1"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/child_2"
        ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/child_3"

        # snippet.json
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
          '{"name": "' + repo_name + '"}',
        ].join($/)

        # parent
        ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/parent", [
          '@snip<child_1>',
          '@snip<child_2>',
          '@snip<child_2>',
          '@snip<child_3>',
          '@snip<child_1>',
          '@snip<child_2>',
          '@snip<child_3>',
        ].join($/)
      end

      let(:input) do
        [
          '@snip <my_repo:parent>',
          '@snip<my_repo:child_3>',
          '@snip<my_repo:child_2>',
          '@snip<my_repo:child_1>',
        ].join($/)
      end

      let(:output) do
        [
          '@snippet <my_repo#master:child_1>',
          '@snippet <my_repo#master:child_2>',
          '@snippet <my_repo#master:child_3>',
          '@snippet <my_repo#master:parent>',
        ].join($/)
      end

      subject { fake_core.api.insert_snippet(input) }
      it { should eq output }

    end

    context "more duplicate cases" do

      context "already snipped" do

        prepare_repository do
          repo_name = "my-repo"
          ref_name = "master"

          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/3"

          # snippet.json
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join($/)

          # src/1
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/1", [
            '@snip<2>',
            '@snip<3>',
          ].join($/)

          # src/2
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/2", [
            '2',
          ].join($/)

          # src/3
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/3", [
            '3',
          ].join($/)
        end # prepare for my-repo

        prepare_repository do
          repo_name = "has-version"
          repo_version = "0.0.1"

          ::FileUtils.mkdir_p "#{tmp_repo_path}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}/.git"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/snippet.json"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/1"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/2"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/3"

          # snippet.json
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join($/)

          # src/1
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/1", [
            '@snip<2>',
            '@snip<3>',
            '0.0.1: 1',
          ].join($/)

          # src/2
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/2", [
            '0.0.1: 2',
          ].join($/)

          # src/3
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/3", [
            '0.0.1: 3',
          ].join($/)
        end # prepare has-version#0.0.1

        prepare_repository do
          repo_name = "has-version"
          repo_version = "1.2.3"

          ::FileUtils.mkdir_p "#{tmp_repo_path}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}/.git"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/snippet.json"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/1"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/2"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/3"

          # snippet.json
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join($/)

          # src/1
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/1", [
            '@snip<2>',
            '@snip<3>',
            '1.2.3: 1',
          ].join($/)

          # src/2
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/2", [
            '1.2.3: 2',
          ].join($/)

          # src/3
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{repo_version}/src/3", [
            '1.2.3: 3',
          ].join($/)
        end # prepare has-version#1.2.3

        context "already snipped using version" do

          context "not already snipped" do

            let(:input) do
              [
                '@snip<has-version#0:1>',
                '@snip<has-version#1:1>',
              ].join($/).freeze
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
              ].join($/).freeze
            end

            subject { fake_core.api.insert_snippet(input) }
            it { should eq output }

          end

          context "snipped", :force => true do

            let(:input) do
              [
                '@snippet<has-version#0.0.1:1>',
                '@snip<has-version#0:1>',
                '@snip<has-version#1:1>',
              ].join($/).freeze
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
              ].join($/).freeze
            end

            subject { fake_core.api.insert_snippet(input) }
            it { should eq output }

          end # snipped

          context "use another repo" do

            let(:input) do
              [
                '@snippet<has-version#0.0.1:1>',
                '@snip<has-version#0:1>',
                '@snip<my-repo:1>',
                '@snip<has-version:1>',
              ].join($/).freeze
            end

            let(:output) do
              [
                '@snippet<has-version#0.0.1:1>',
                '@snippet<my-repo#master:2>',
                '2',
                '@snippet<my-repo#master:3>',
                '3',
                '@snippet<my-repo#master:1>',
                '@snippet<has-version#1.2.3:2>',
                '1.2.3: 2',
                '@snippet<has-version#1.2.3:3>',
                '1.2.3: 3',
                '@snippet<has-version#1.2.3:1>',
                '1.2.3: 1',
              ].join($/).freeze
            end

            subject { fake_core.api.insert_snippet(input) }
            it { should eq output }

          end

        end # already snipped using version

        context "already snipped case" do

          let(:input) do
            [
              '@snippet<my-repo#master:3>',
              '3',
              '',
              '@snip<my-repo:1>',
              '@snip<my-repo:2>',
            ].join($/)
          end

          let(:output) do
            [
              '@snippet<my-repo#master:3>',
              '3',
              '',
              '@snippet<my-repo#master:2>',
              '2',
              '@snippet<my-repo#master:1>',
            ].join($/)
          end

          subject { fake_core.api.insert_snippet(input) }
          it { should eq output }

        end # already snipped case

        context "not already snipped case" do

          let(:input) do
            [
              '@snip<my-repo:1>',
              '@snip<my-repo:2>',
              '@snip<my-repo:3>',
            ].join($/)
          end

          let(:output) do
            [
              '@snippet<my-repo#master:2>',
              '2',
              '@snippet<my-repo#master:3>',
              '3',
              '@snippet<my-repo#master:1>',
            ].join($/)
          end

          subject { fake_core.api.insert_snippet(input) }
          it { should eq output }

        end # not already snipped case

      end # alread snipped

      context "other repos have same snip tag" do

        prepare_repository do
          repo_name = "my_lib"
          ref_name = "master"

          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/lib"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/lib/add_func.cpp"

          # snippet.json
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
            '{',
            '  "name": "' + repo_name + '",',
            '  "main": "src"',
            '}',
          ].join($/)

          # src/add_func.cpp
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/src/add_func.cpp", [
            'int add_func( int a, int b ) {',
            '  return a + b;',
            '}',
          ].join($/)
        end # prepare for my_lib repo

        prepare_repository do
          repo_name = "my_repo_a"
          ref_name = "master"

          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/use_add_func.cpp"

          # snippet.json
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [
            '{"name": "' + repo_name + '"}',
          ].join($/)

          # use_add_func.cpp
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/use_add_func.cpp", [
            '// @snip <my_lib:add_func.cpp>',
            'int my_repo_a_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
          ].join($/)
        end # prepare for my_repo_a repo

        prepare_repository do
          repo_name = "my_repo_b"
          ref_name = "master"

          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}"
          ::FileUtils.mkdir_p "#{tmp_repo_path}/#{repo_name}/#{ref_name}/.git"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json"
          ::FileUtils.touch   "#{tmp_repo_path}/#{repo_name}/#{ref_name}/use_add_func.cpp"

          # snippet.json
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/snippet.json", [

            '{"name": "' + repo_name + '"}',
          ].join($/)

          # use_add_func.cpp
          ::File.write "#{tmp_repo_path}/#{repo_name}/#{ref_name}/use_add_func.cpp", [
            '// @snip <my_lib:add_func.cpp>',
            'int my_repo_b_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
          ].join($/)
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
          ].join($/)
        end

        let(:output) do
          [
            '#include <iostream>',
            '',
            '// @snippet<my_lib#master:add_func.cpp>',
            'int add_func( int a, int b ) {',
            '  return a + b;',
            '}',
            '// @snippet<my_repo_a#master:use_add_func.cpp>',
            'int my_repo_a_use_add_func( int a, int b ) {',
            '  return add_func(a, b);',
            '}',
            '// @snippet<my_repo_b#master:use_add_func.cpp>',
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
          ].join($/)
        end

        context "call insert_snippet" do
          subject { fake_core.api.insert_snippet(input) }
          it { should eq output }
        end

      end # other repos have same snip tags

    end # more duplicate cases

    context "filters" do

      context "range cut (simple)" do

        prepare_repository do
          ::FileUtils.touch "./file1.cpp"
          ::File.write "./file1.cpp", [
            "// @begin_cut",
            "#include <path/to/lib>",
            "// @end_cut",
            "void func() {",
            "}",
          ].join($/)
        end

        let(:input) do
          [
            "// @snip <./file1.cpp>",
          ].join($/)
        end

        let(:output) do
          [
            "// @snippet <file1.cpp>",
            "void func() {",
            "}",
          ].join($/)
        end

        subject { fake_core.api.insert_snippet(input) }
        it { should eq output }

      end # range cut

      context "range cut (nested snippet)" do

        prepare_repository do
          ::FileUtils.touch "./file1.cpp"
          ::File.write "./file1.cpp", [
            "// @begin_cut",
            "#include <path/to/lib>",
            "// @end_cut",
            "// @snip <./file2.cpp>",
            "void func1() {",
            "}",
          ].join($/)
          ::File.write "./file2.cpp", [
            "// @begin_cut",
            "#include <path/to/lib>",
            "// @end_cut",
            "void func2() {",
            "}",
          ].join($/)
        end

        let(:input) do
          [
            "// @snip <./file1.cpp>",
          ].join($/)
        end

        let(:output) do
          [
            "// @snippet <file2.cpp>",
            "void func2() {",
            "}",
            "// @snippet <file1.cpp>",
            "void func1() {",
            "}",
          ].join($/)
        end

        subject { fake_core.api.insert_snippet(input) }
        it { should eq output }

      end # range cut (nested)

      context "cut line" do

        prepare_repository do
          ::FileUtils.touch "./file1.cpp"
          ::File.write "./file1.cpp", [
            "#include <path/to/lib> // @cut",
            "void func() {",
            "}",
          ].join($/)
        end

        let(:input) do
          [
            "// @snip <./file1.cpp>",
          ].join($/)
        end

        let(:output) do
          [
            "// @snippet <file1.cpp>",
            "void func() {",
            "}",
          ].join($/)
        end

        subject { fake_core.api.insert_snippet(input) }
        it { should eq output }

      end # cut line

      context "cut line (nested case)" do

        prepare_repository do
          ::FileUtils.touch "./file1.cpp"
          ::File.write "./file1.cpp", [
            "#include <path/to/lib> // @cut",
            "// @snip <./file2.cpp>",
            "void func1() {",
            "}",
          ].join($/)
          ::File.write "./file2.cpp", [
            "#include <path/to/lib> // @cut",
            "void func2() {",
            "}",
          ].join($/)
        end

        let(:input) do
          [
            "// @snip <./file1.cpp>",
          ].join($/)
        end

        let(:output) do
          [
            "// @snippet <file2.cpp>",
            "void func2() {",
            "}",
            "// @snippet <file1.cpp>",
            "void func1() {",
            "}",
          ].join($/)
        end

        subject { fake_core.api.insert_snippet(input) }
        it { should eq output }

      end

    end # filters

    context "snippet's context testing" do

      context "Golang Project 1" do

        prepare_repository do
          ::FileUtils.mkdir "./runner"
          ::FileUtils.touch "./runner/runner.go"
          ::FileUtils.mkdir "./solver"
          ::FileUtils.touch "./solver/input.go"
          ::FileUtils.touch "./solver/output.go"
          ::FileUtils.touch "./solver/solver.go"
          ::FileUtils.mkdir "./typedef"
          ::FileUtils.touch "./typedef/typedef.go"
          ::FileUtils.touch "./main.go"

          ::File.write "./runner/runner", [
            "// @snip <../solver/solver.go>",
          ].join($/)

          ::File.write "./solver/input.go", [
            "type Input struct {",
            "  eof bool",
            "}",
          ].join($/)

          ::File.write "./solver/output.go", [
            "type Output struct {",
            "}",
          ].join($/)

          ::File.write "./solver/solver.go", [
            "// @snip <./input.go>",
            "// @snip <./output.go>",
            "",
            "type Solver struct {",
              "in *Input",
              "out *Output",
            "}",
            "",
            "func (s *Solver) input() *Input {",
              "return s.in",
            "}",
            "",
            "func CreateSolver() *Solver {",
              "s := new(Solver)",
              "s.in = new(Input)",
              "s.out = new(Output)",
              "return s",
            "}",
          ].join($/)

          ::File.write "./typedef/typedef.go", [
            "type Int int64",
          ].join($/)

          ::File.write "main.go", [
            "package main",
            "",
            "// @snip <./typedef/typedef.go>",
            "// @snip <./solver/solver.go>",
            "// @snip <./runner/runner.go>",
            "",
            "func main() {",
            "}",
            "",
          ].join($/)
        end

        context "snip from main.go directly" do

          let(:input) { ::File.read "main.go" }

          let(:output) do
            [
              "package main",
              "",
              "// @snippet <typedef/typedef.go>",
              "type Int int64",
              "// @snippet <solver/input.go>",
              "type Input struct {",
              "  eof bool",
              "}",
              "// @snippet <solver/output.go>",
              "type Output struct {",
              "}",
              "// @snippet <solver/solver.go>",
              "",
              "type Solver struct {",
                "in *Input",
                "out *Output",
              "}",
              "",
              "func (s *Solver) input() *Input {",
                "return s.in",
              "}",
              "",
              "func CreateSolver() *Solver {",
                "s := new(Solver)",
                "s.in = new(Input)",
                "s.out = new(Output)",
                "return s",
              "}",
              "// @snippet <runner/runner.go>",
              "",
              "func main() {",
              "}",
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end # snip from main.go directly

        context "snip main.go" do

          let(:input) do
            [
              "// @snip <main.go>",
            ].join($/)
          end

          let(:output) do
            [
              "// @snippet <typedef/typedef.go>",
              "type Int int64",
              "// @snippet <solver/input.go>",
              "type Input struct {",
              "  eof bool",
              "}",
              "// @snippet <solver/output.go>",
              "type Output struct {",
              "}",
              "// @snippet <solver/solver.go>",
              "",
              "type Solver struct {",
                "in *Input",
                "out *Output",
              "}",
              "",
              "func (s *Solver) input() *Input {",
                "return s.in",
              "}",
              "",
              "func CreateSolver() *Solver {",
                "s := new(Solver)",
                "s.in = new(Input)",
                "s.out = new(Output)",
                "return s",
              "}",
              "// @snippet <runner/runner.go>",
              "// @snippet <main.go>",
              "package main",
              "",
              "",
              "func main() {",
              "}",
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end # snip main.go

      end # Golang Project 1

      context "../" do

        prepare_repository do
          ::FileUtils.mkdir "./foo"
          ::FileUtils.touch "./foo/foo.go"
          ::FileUtils.mkdir "./bar"
          ::FileUtils.touch "./bar/bar.go"

          ::File.write "./foo/foo.go", [
            "// @begin_cut",
            "package foo",
            "// @end_cut",
            "func Foo() {",
            "}",
          ].join($/)

          ::File.write "./bar/bar.go", [
            "// @begin_cut",
            "package bar",
            "import \"../foo\"",
            "// @end_cut",
            "// @snip <../foo/foo.go>",
            "func Bar() {",
            "}",
          ].join($/)
        end

        let(:input) do
          [
            "// @snip <./foo/foo.go>",
            "// @snip <./bar/bar.go>",
          ].join($/)
        end

        let(:output) do
          [
            "// @snippet <foo/foo.go>",
            "func Foo() {",
            "}",
            "// @snippet <bar/bar.go>",
            "func Bar() {",
            "}",
          ].join($/)
        end

        subject { fake_core.api.insert_snippet input }
        it { should eq output }

      end

    end

    context "@no_tag" do

      context "no_tag is in cut range" do

        prepare_repository do
          ::FileUtils.touch "proxy.rb"
          ::FileUtils.touch "foo.rb"
          ::FileUtils.mkdir "foo"
          ::FileUtils.touch "foo/func1.rb"
          ::FileUtils.touch "foo/func2.rb"
          ::FileUtils.touch "foo/func3.rb"

          ::File.write "proxy.rb", [
            "# @snip <foo.rb>",
            "# @begin_cut",
            "# @no_tag",
            "# @end_cut",
          ].join($/)

          ::File.write "foo.rb", [
            "# @begin_cut",
            "# @no_tag",
            "# @end_cut",
            "# @snip <foo/func1.rb>",
            "# @snip <foo/func2.rb>",
            "# @snip <foo/func3.rb>",
          ].join($/)

          ::File.write "foo/func1.rb", [
            "def func1",
            "  1",
            "end",
          ].join($/)

          ::File.write "foo/func2.rb", [
            "def func2",
            "  2",
            "end",
          ].join($/)

          ::File.write "foo/func3.rb", [
            "def func3",
            "  3",
            "end",
          ].join($/)
        end

        context "snip foo.rb" do

          let(:input) do
            [
              "# @snip <foo.rb>",
            ].join($/)
          end

          let(:output) do
            [
              "# @snippet <foo/func1.rb>",
              "def func1",
              "  1",
              "end",
              "# @snippet <foo/func2.rb>",
              "def func2",
              "  2",
              "end",
              "# @snippet <foo/func3.rb>",
              "def func3",
              "  3",
              "end",
              "# @snippet <foo.rb>",
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end # snip foo.rb

        context "snip proxy.rb" do

          let(:input) do
            [
              "# @snip <proxy.rb>",
            ].join($/)
          end

          let(:output) do
            [
              "# @snippet <foo/func1.rb>",
              "def func1",
              "  1",
              "end",
              "# @snippet <foo/func2.rb>",
              "def func2",
              "  2",
              "end",
              "# @snippet <foo/func3.rb>",
              "def func3",
              "  3",
              "end",
              "# @snippet <foo.rb>",
              "# @snippet <proxy.rb>",
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end # snip proxy.rb

      end

      context "for ruby module" do

        prepare_repository do
          ::FileUtils.touch "proxy.rb"
          ::FileUtils.touch "foo.rb"
          ::FileUtils.mkdir "foo"
          ::FileUtils.touch "foo/func1.rb"
          ::FileUtils.touch "foo/func2.rb"
          ::FileUtils.touch "foo/func3.rb"

          ::File.write "proxy.rb", [
            "# @snip <foo.rb>",
            "# @no_tag",
          ].join($/)

          ::File.write "foo.rb", [
            "# @no_tag",
            "# @snip <foo/func1.rb>",
            "# @snip <foo/func2.rb>",
            "# @snip <foo/func3.rb>",
          ].join($/)

          ::File.write "foo/func1.rb", [
            "def func1",
            "  1",
            "end",
          ].join($/)

          ::File.write "foo/func2.rb", [
            "def func2",
            "  2",
            "end",
          ].join($/)

          ::File.write "foo/func3.rb", [
            "def func3",
            "  3",
            "end",
          ].join($/)
        end

        context "snip foo.rb" do

          let(:input) do
            [
              "# @snip <foo.rb>",
            ].join($/)
          end

          let(:output) do
            [
              "# @snippet <foo/func1.rb>",
              "def func1",
              "  1",
              "end",
              "# @snippet <foo/func2.rb>",
              "def func2",
              "  2",
              "end",
              "# @snippet <foo/func3.rb>",
              "def func3",
              "  3",
              "end",
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end # snip foo.rb

        context "snip proxy.rb" do

          let(:input) do
            [
              "# @snip <proxy.rb>",
            ].join($/)
          end

          let(:output) do
            [
              "# @snippet <foo/func1.rb>",
              "def func1",
              "  1",
              "end",
              "# @snippet <foo/func2.rb>",
              "def func2",
              "  2",
              "end",
              "# @snippet <foo/func3.rb>",
              "def func3",
              "  3",
              "end",
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end # snip proxy.rb

        context "add nested module" do

          prepare_repository do
            ::FileUtils.touch "foo/bar.rb"
            ::FileUtils.mkdir "foo/bar"
            ::FileUtils.touch "foo/bar/func1.rb"
            ::FileUtils.touch "foo/bar/func2.rb"
            ::FileUtils.touch "foo/bar/func3.rb"

            ::File.write "foo.rb", [
              "# @no_tag",
              "# @snip <foo/func1.rb>",
              "# @snip <foo/func2.rb>",
              "# @snip <foo/func3.rb>",
              "# @snip <foo/bar.rb>",
            ].join($/)

            ::File.write "foo/bar.rb", [
              "# @no_tag",
              "# @snip <bar/func1.rb>",
              "# @snip <bar/func2.rb>",
              "# @snip <bar/func3.rb>",
            ].join($/)

            ::File.write "foo/bar/func1.rb", [
              "def bfunc1",
              "  1",
              "end",
            ].join($/)

            ::File.write "foo/bar/func2.rb", [
              "def bfunc2",
              "  2",
              "end",
            ].join($/)

            ::File.write "foo/bar/func3.rb", [
              "def bfunc3",
              "  3",
              "end",
            ].join($/)
          end

          context "snip foo.rb" do

            let(:input) do
              [
                "# @snip <foo.rb>",
              ].join($/)
            end

            let(:output) do
              [
                "# @snippet <foo/func1.rb>",
                "def func1",
                "  1",
                "end",
                "# @snippet <foo/func2.rb>",
                "def func2",
                "  2",
                "end",
                "# @snippet <foo/func3.rb>",
                "def func3",
                "  3",
                "end",
                "# @snippet <foo/bar/func1.rb>",
                "def bfunc1",
                "  1",
                "end",
                "# @snippet <foo/bar/func2.rb>",
                "def bfunc2",
                "  2",
                "end",
                "# @snippet <foo/bar/func3.rb>",
                "def bfunc3",
                "  3",
                "end",
              ].join($/)
            end

            subject { fake_core.api.insert_snippet input }
            it { should eq output }

          end

          context "snip proxy.rb" do

            let(:input) do
              [
                "# @snip <proxy.rb>",
              ].join($/)
            end

            let(:output) do
              [
                "# @snippet <foo/func1.rb>",
                "def func1",
                "  1",
                "end",
                "# @snippet <foo/func2.rb>",
                "def func2",
                "  2",
                "end",
                "# @snippet <foo/func3.rb>",
                "def func3",
                "  3",
                "end",
                "# @snippet <foo/bar/func1.rb>",
                "def bfunc1",
                "  1",
                "end",
                "# @snippet <foo/bar/func2.rb>",
                "def bfunc2",
                "  2",
                "end",
                "# @snippet <foo/bar/func3.rb>",
                "def bfunc3",
                "  3",
                "end",
              ].join($/)
            end

            subject { fake_core.api.insert_snippet input }
            it { should eq output }

          end # snip proxy

        end # add nested module

      end # for ruby module

    end # @no_tag

    describe "not found case" do

      context "create project on current directory" do

        prepare_repository do
          ::FileUtils.touch "snippet.c"
          ::FileUtils.mkdir_p "path/to"
          ::FileUtils.touch "path/to/found.c"

          ::File.write "snippet.c", [
            "/* @snip <path/to/found.c> */",
            "/* @snip <path/to/not_found.c> */",
          ].join($/)
        end

        context "snip snippet.c" do

          let(:input) do
            [
              "/* @snip<snippet.c> */",
            ].join($/)
          end

          let(:output) do
            [
              "/* @snippet<path/to/found.c> */",
              "/* @snippet<path/to/not_found.c> */",
              "ERROR: No such file or directory - ./path/to/not_found.c",
              "/* @snippet<snippet.c> */",
            ].join($/)
          end

          subject { fake_core.api.insert_snippet input }
          it { should eq output }

        end # snip snippet.c

      end # create project on current directory

    end # not found case

  end # insert_snippet

end # SocialSnippet::Core
