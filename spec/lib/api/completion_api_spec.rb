require "spec_helper"

describe ::SocialSnippet::Api::CompletionApi, :current => true do

  context "prepare repos" do

    before do
      # create normal repo
      repo = ::SocialSnippet::Repository::Models::Repository.create(
        :name => "repo-a",
      )
      repo.add_ref "1.2.3", "rev-1.2.3"
      repo.add_package "1.2.3"

      # create package
      # src/
      #   file/
      #     sub_file_1.cpp
      #     sub_file_2.cpp
      #     sub_file_3.cpp
      #   file.cpp
      # snippet.json
      package = ::SocialSnippet::Repository::Models::Package.create(
        :repo_name => "repo-a",
        :rev_hash => "rev-1.2.3",
      )
      package.add_directory "src"
      package.add_directory "src/file"
      package.add_file "snippet.json", {
        :name => "repo-a",
        :main => "src",
      }.to_json
      package.add_file "src/file.cpp", ""
      package.add_file "src/file/sub_file_1.cpp", ""
      package.add_file "src/file/sub_file_2.cpp", ""
      package.add_file "src/file/sub_file_3.cpp", ""
    end

    before do
      # create no-main repo
      repo = ::SocialSnippet::Repository::Models::Repository.create(
        :name => "repo-no-main",
      )
      repo.add_ref "0.0.0", "rev-0.0.0"
      repo.add_package "0.0.0"

      # create package
      # file/
      #   sub_file.cpp
      # snippet.json
      # file.cpp
      package = ::SocialSnippet::Repository::Models::Package.create(
        :repo_name => "repo-no-main",
        :rev_hash => "rev-0.0.0",
      )
      package.add_directory "file"
      package.add_file "snippet.json", {
        :name => "repo-no-main",
      }.to_json
      package.add_file "file.cpp", ""
      package.add_file "file/sub_file.cpp", ""
    end

    context "complete // @snip" do
      subject do
        lambda { fake_core.api.complete_snippet_path "//" }
      end
      it { should raise_error }
    end

    context "complete // @snip <" do
      subject { fake_core.api.complete_snippet_path "// @snip <" }
      it { should be_empty }
    end

    context "complete // @snip<re" do
      subject { fake_core.api.complete_snippet_path "// @snip <re" }
      it { should include "repo-a" }
      it { should include "repo-no-main" }
    end

    context "complete // @snip<repo-n" do
      subject { fake_core.api.complete_snippet_path "// @snip <re" }
      it { should_not include "repo-a" }
      it { should include "repo-no-main" }
    end

    context "complete // @snip<repo-a:" do
      subject { fake_core.api.complete_snippet_path "// @snip <repo-a:" }
      it { expect(subject.length).to eq 2 }
      it { should include "file.cpp>" }
      it { should include "file/" }
    end

    context "complete // @snip<repo-a:file" do
      subject { fake_core.api.complete_snippet_path "// @snip <repo-a:file" }
      it { expect(subject.length).to eq 2 }
      it { should include "file.cpp>" }
      it { should include "file/" }
    end

    context "complete // @snip<repo-a:file." do
      subject { fake_core.api.complete_snippet_path "// @snip <repo-a:file." }
      it { expect(subject.length).to eq 1 }
      it { should include "file.cpp>" }
    end

    context "complete // @snip<repo-a:file/" do
      subject { fake_core.api.complete_snippet_path "// @snip <repo-a:file/" }
      it { expect(subject.length).to eq 3 }
      it { should include "sub_file_1.cpp>" }
      it { should include "sub_file_2.cpp>" }
      it { should include "sub_file_3.cpp>" }
    end

    context "complete // @snip <repo-no-main:" do
      subject { fake_core.api.complete_snippet_path "// @snip <repo-no-main:" }
      it { expect(subject.length).to eq 3 }
      it { should include "file.cpp>" }
      it { should include "snippet.json>" }
      it { should include "file/" }
    end

  end # prepare repos

end # ::SocialSnippet::Api::CompletionApi

