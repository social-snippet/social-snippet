require "spec_helper"

describe ::SocialSnippet::Repository::Drivers::DriverBase do

  let(:repo_url) { "git://github.com/user/repo" }
  let(:repo_name) { "my-repo" }
  let(:driver) do
    ::SocialSnippet::Repository::Drivers::DriverBase.new repo_url
  end

  before do
    allow(driver).to receive(:fetch).and_return true
  end

  before do
    allow(driver).to receive(:snippet_json) do
      {
        "name" => "my-repo",
      }
    end
  end

  before do
    allow(driver).to receive(:current_ref) do
      "master"
    end
  end

  before do
    allow(driver).to receive(:refs).and_return [
      "0.0.0",
      "0.0.1",
      "0.0.2",
    ]
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
        "rev-0.0.0"
      when "0.0.1"
        "rev-0.0.1"
      when "0.0.2"
        "rev-0.0.2"
      else
        raise "error"
      end
    end
  end

  before do
    allow(driver).to(
      receive(:each_directory)
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir1")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir2")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir3")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir2")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir3")
    )
  end

  before do
    allow(driver).to(
      receive(:each_file)
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "file1", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/file2", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir1/file3", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir2/file4", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir1/subdir3/file5", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir2/file6", "")
        .and_yield(::SocialSnippet::Repository::Drivers::Entry.new "dir3/file7", "")
    )
  end

  context "driver.latest_version" do
    subject { driver.latest_version }
    it { should eq "0.0.2" }
  end

end # ::SocialSnippet::Repository::Drivers::DriverBase

