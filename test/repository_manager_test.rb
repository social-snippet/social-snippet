require "spec_helper"

describe ::SocialSnippet::Repository::RepositoryManager do

  let(:config) do
    ::SocialSnippet::Config.new(social_snippet)
  end

  let(:social_snippet) do
    class Fake; end
    fake = Fake.new
    fake
  end

  before do
    allow(social_snippet).to receive(:storage).and_return fake_storage
    allow(social_snippet).to receive(:logger).and_return fake_logger
    allow(social_snippet).to receive(:config).and_return config
  end
  
  let(:repo_manager) do
    ::SocialSnippet::Repository::RepositoryManager.new(social_snippet)
  end

  describe "complete (repo)" do
    
    before do
      install_path = "/path/to/install/path"
      FileUtils.mkdir_p "#{install_path}"
      FileUtils.mkdir_p "#{install_path}/my-repo"
      FileUtils.mkdir_p "#{install_path}/new-repo"
      FileUtils.mkdir_p "#{install_path}/my-math-repo"
      FileUtils.mkdir_p "#{install_path}/myrepo"
      allow(repo_manager.installer).to receive(:path).and_return install_path
    end # prepare files

    context "key = my-" do
      it { expect(repo_manager.complete "@snip <my-").to      include "my-repo" }
      it { expect(repo_manager.complete "@snip <my-").to_not  include "new-repo" }
      it { expect(repo_manager.complete "@snip <my-").to      include "my-math-repo" }
    end

    context "key = new-" do
      it { expect(repo_manager.complete "@snip <new-").to_not  include "my-repo" }
      it { expect(repo_manager.complete "@snip <new-").to      include "new-repo" }
      it { expect(repo_manager.complete "@snip <new-").to_not  include "my-math-repo" }
    end

  end # complete (repo)

  describe "is_completing_file_path?" do

    context "valid cases" do
      it { expect(repo_manager.is_completing_file_path? "// @snip <repo:").to be_truthy }
      it { expect(repo_manager.is_completing_file_path? "# @snippet <repo:path").to be_truthy }
      it { expect(repo_manager.is_completing_file_path? "# @snippet<my-repo:path/to").to be_truthy }
      it { expect(repo_manager.is_completing_file_path? "@snip<my_repo:path/to/file.cpp").to be_truthy }
      it { expect(repo_manager.is_completing_file_path? "@snip <repo:path/to").to be_truthy }
      it { expect(repo_manager.is_completing_file_path? "@snippet <repo:path/to/").to be_truthy }
      it { expect(repo_manager.is_completing_file_path? "@snippet <my-repo:path/to/file").to be_truthy }
      it { expect(repo_manager.is_completing_file_path? "//@snip<my_repo:path/to/fi").to be_truthy }
    end # valid cases

    context "invalid cases" do
      it { expect(repo_manager.is_completing_file_path? "@snip <repo").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "@snippet <repo#").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "@snippet <my-repo").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "// @snip<my_repo").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "// @snip <repo:>").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "# @snippet <repo:path>").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "# @snippet<my-repo:path/to>").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "@snip<my_repo:path/to/file.cpp>").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "@snip <repo:path/to>").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "@snippet <repo:path/to/>").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "@snippet <my-repo:path/to/file>").to be_falsey }
      it { expect(repo_manager.is_completing_file_path? "//@snip<my_repo:path/to/fi>").to be_falsey }
    end

  end # is_completing_repo_name?

  describe "is_completing_repo_name?" do

    context "valid cases" do
      it { expect(repo_manager.is_completing_repo_name? "@snip <repo").to be_truthy }
      it { expect(repo_manager.is_completing_repo_name? "@snippet <repo").to be_truthy }
      it { expect(repo_manager.is_completing_repo_name? "@snippet <my-repo").to be_truthy }
      it { expect(repo_manager.is_completing_repo_name? "@snip<my_repo").to be_truthy }
    end # valid cases

    context "invalid cases" do
      it { expect(repo_manager.is_completing_repo_name? "@snip <repo:").to be_falsey }
      it { expect(repo_manager.is_completing_repo_name? "@snippet <repo#").to be_falsey }
      it { expect(repo_manager.is_completing_repo_name? "@snippet <my-repo:").to be_falsey }
      it { expect(repo_manager.is_completing_repo_name? "@snip<my_repo:").to be_falsey }
      it { expect(repo_manager.is_completing_repo_name? "@snip <repo>").to be_falsey }
      it { expect(repo_manager.is_completing_repo_name? "@snippet <repo>").to be_falsey }
      it { expect(repo_manager.is_completing_repo_name? "@snippet <my-repo>").to be_falsey }
      it { expect(repo_manager.is_completing_repo_name? "@snip<my_repo>").to be_falsey }
    end

  end # is_completing_repo_name?

end # ::SocialSnippet::Repository::RepositoryManager

