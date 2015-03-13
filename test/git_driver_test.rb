require "spec_helper"

module ::SocialSnippet::Repository

  describe Drivers::GitDriver do

    class FakeClass; end

    def create_fake_instance
      FakeClass.new
    end

    def create_branch(name)
      branch = create_fake_instance
      allow(branch).to receive(:name).and_return "refs/remotes/origin/#{name}"
      branch
    end

    def create_tag(name)
      branch = create_fake_instance
      allow(branch).to receive(:name).and_return "refs/tags/#{name}"
      branch
    end

    before do
      class FakeDriver < Drivers::GitDriver; end
      allow(Rugged::Repository).to receive(:new) do
        rugged_repo = create_fake_instance

        allow(rugged_repo).to receive(:references).and_return [
          create_branch("master"),
          create_branch("develop"),
          create_tag("0.0.1"),
          create_tag("0.0.2"),
        ]
        rugged_repo
      end
      @repo = FakeDriver.new(fake_core, "/path/to/repo")
    end

    describe "#refs" do
      it { expect(@repo.refs.length).to eq 4 }
      it { expect(@repo.refs).to include "master" }
      it { expect(@repo.refs).to include "develop" }
      it { expect(@repo.refs).to include "0.0.1" }
      it { expect(@repo.refs).to include "0.0.2" }
    end

    describe "#remote_refs" do
      it { expect(@repo.remote_refs.length).to eq 2 }
      it { expect(@repo.remote_refs).to include "master" }
      it { expect(@repo.remote_refs).to include "develop" }
      it { expect(@repo.remote_refs).to_not include "0.0.1" }
      it { expect(@repo.remote_refs).to_not include "0.0.2" }
    end

  end

  describe Drivers::GitDriver, :without_fakefs => true do

    before do
      disable_fakefs
      make_fake_home
    end

    before do
      @curdir = ::Dir.pwd
      @tmpdir = ::Dir.mktmpdir
      ::Dir.chdir @tmpdir
    end

    after do
      ::Dir.chdir @curdir
      ::FileUtils.rm_r @tmpdir
    end

    context "clone example-repo" do
      before do
        @cloned_repo = fake_core.repo_factory.clone "git://github.com/social-snippet/example-repo"
      end

      context "checkout 1.0.0" do
        before do
          @cloned_repo.checkout "1.0.0"
        end

        context "load snippet json" do
          before do
            @cloned_repo.load_snippet_json
          end

          context "create cache" do

            before do
              @cloned_repo.create_cache("./cache")
            end

            it do
              expect(@cloned_repo.commit_id).to eq "efa58ecae07cf3d063ae75fa97fce164c56d205a"
            end

            it do
              expect(::File.exists?("#{@cloned_repo.cache_path}")).to be_truthy
            end

          end
        end
      end

    end # clone example-repo

  end # Drivers::GitDriver

end # ::SocialSnippet::Repository
