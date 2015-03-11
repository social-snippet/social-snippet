require "spec_helper"

describe ::SocialSnippet::Repository::Models::Package do

  let(:repo_name) { "my-repo" }
  let(:rev_hash) { "commit-id" }
  let(:package) do
    ::SocialSnippet::Repository::Models::Package.new(
      :repo_name => repo_name,
      :rev_hash => rev_hash,
    )
  end

  before { ::SocialSnippet::Repository::Models::Package.core = fake_core }

  context "add snippet.json" do

    before do
      package.add_system_file "snippet.json", {
        :name => "package-name",
        :desc => "package-desc",
        :main => "package-main"
      }.to_json
    end

    context "check snippet.json" do
      it { expect(package.snippet_json["name"]).to eq "package-name" }
      it { expect(package.snippet_json["desc"]).to eq "package-desc" }
      it { expect(package.snippet_json["main"]).to eq "package-main" }
    end

    describe "#paths" do

      context "add file" do
        before { package.add_file "file", "file-data" }
        subject { package.paths }
        it { should include "file" }
        context "check filesystem" do
          subject { ::FileTest.file? fake_core.config.package_path(repo_name, rev_hash, ::File.join("package-main", "file")) }
          it { should be_truthy }
        end
      end

      context "add dir" do
        before { package.add_directory "dir" }
        subject { package.paths }
        it { should include "dir/" }
        context "check filesystem" do
          subject { ::FileTest.directory? fake_core.config.package_path(repo_name, rev_hash, ::File.join("package-main", "dir")) }
          it { should be_truthy }
        end
        context "add dir/file" do
          before { package.add_file "dir/file", "dir/file-data" }
          subject { package.paths }
          it { should include "dir/file" }
          context "check filesystem" do
            subject { ::FileTest.file? fake_core.config.package_path(repo_name, rev_hash, ::File.join("package-main", "dir/file")) }
            it { should be_truthy }
          end
        end
      end

      context "add dir/" do
        before { package.add_directory "dir/" }
        subject { package.paths }
        it { should include "dir/" }
        context "check filesystem" do
          subject { ::FileTest.directory? fake_core.config.package_path(repo_name, rev_hash, ::File.join("package-main", "dir")) }
          it { should be_truthy }
        end
      end

    end # files

    describe "#glob" do

      context "prepare files" do

        before do
          package.add_file "file1.cpp", ""
          package.add_file "file2.rb", ""
          package.add_file "file3.cpp", ""
          package.add_directory "subdir"
          package.add_file "subdir/file4.cpp", ""
          package.add_file "subdir/file5.rb", ""
        end

        context "glob *.cpp" do
          subject { package.glob "*.cpp" }
          it { should include "file1.cpp" }
          it { should_not include "file2.rb" }
          it { should include "file3.cpp" }
          it { should_not include "subdir/file4.cpp" }
          it { should_not include "subdir/file5.rb" }
        end

        context "glob subdir/*.rb" do
          subject { package.glob "subdir/*.rb" }
          it { should_not include "file1.cpp" }
          it { should_not include "file2.rb" }
          it { should_not include "file3.cpp" }
          it { should_not include "subdir/file4.cpp" }
          it { should include "subdir/file5.rb" }
        end

      end

    end #glob

    describe "serialization" do

      context "prepare files" do

        before do
          package.add_file "file1.cpp", ""
          package.add_file "file2.rb", ""
          package.add_file "file3.cpp", ""
          package.add_directory "subdir"
          package.add_file "subdir/file4.cpp", ""
          package.add_file "subdir/file5.rb", ""
        end

        context "save package" do

          before { package.save! }

          context "load package" do
            let(:loaded_package) do
              ::SocialSnippet::Repository::Models::Package.find_by(
                :repo_name => "my-repo",
                :rev_hash => "commit-id",
              )
            end

            context "glob *.cpp" do
              subject { loaded_package.glob "*.cpp" }
              it { should include "file1.cpp" }
              it { should_not include "file2.rb" }
              it { should include "file3.cpp" }
              it { should_not include "subdir/file4.cpp" }
              it { should_not include "subdir/file5.rb" }
            end

            context "glob subdir/*.rb" do
              subject { loaded_package.glob "subdir/*.rb" }
              it { should_not include "file1.cpp" }
              it { should_not include "file2.rb" }
              it { should_not include "file3.cpp" }
              it { should_not include "subdir/file4.cpp" }
              it { should include "subdir/file5.rb" }
            end

          end

        end

      end # save package

    end # serialization

  end # add snippet.json

end # ::SocialSnippet::Repository::Models::Package


