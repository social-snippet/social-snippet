require "spec_helper"

describe ::SocialSnippet::Repository::Drivers::DriverBase, :current => true do

  let(:repo_url) { "git://github.com/user/repo" }
  let(:driver) do
    ::SocialSnippet::Repository::Drivers::DriverBase.new fake_core, repo_url
  end

  before do
    allow(driver).to receive(:fetch).and_return true
  end

  before do
    allow(driver).to receive(:snippet_json) do
      {
        "name" => "repo",
      }
    end
  end

  before do
    allow(driver).to receive(:current_ref) do
      "master"
    end
  end

  before do
    allow(driver).to receive(:rev_hash) do |ref|
      case ref
      when "master"
        "rev-master"
      when "develop"
        "rev-develop"
      when "feature/abc"
        "rev-feature-abc"
      when "0.0.0"
        "0.0.0"
      when "0.0.1"
        "0.0.1"
      when "0.0.2"
        "0.0.2"
      else
        raise "error"
      end
    end
  end

  before do
    allow(driver).to(
      receive(:each_directory)
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir2/subdir1")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir2")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir3")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir2")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir3")
    )
  end

  before do
    allow(driver).to(
      receive(:each_content)
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "file1", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/file2", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir2/subdir1/file3", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir2/file4", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir3/file5", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir2/file6", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir3/file7", "")
    )
  end

  before do
    allow(driver).to(
      receive(:each_ref)
        .and_yield("master")
        .and_yield("develop")
        .and_yield("feature/abc")
        .and_yield("0.0.0")
        .and_yield("0.0.1")
        .and_yield("0.0.2")
    )
  end

  context "driver.fetch" do

    before { driver.fetch }

    context "driver.cache" do

      before { driver.cache }

      context "::SocialSnippet::Repository::Models::Repository.find repo" do

        let(:repo) do
          ::SocialSnippet::Repository::Models::Repository.find_by(:url => repo_url)
        end

        context "repo.name" do
          subject { repo.name }
          it { should eq "repo" }
        end

      end

    end

  end

end # ::SocialSnippet::Repository::Drivers::DriverBase

