require "spec_helper"

describe SocialSnippet::Context do

  let(:context) { SocialSnippet::Context.new("path/to/file.cpp") }

  describe "#move()" do

    context "move ./file2.cpp" do

      before { context.move "./file2.cpp" }

      context "#path" do
        subject { context.path }
        it { should eq "path/to/file2.cpp" }
      end

      context "#repo" do
        subject { context.repo }
        it { should be_nil }
      end

      context "move path/to/file.cpp, repo" do

        before { context.move "path/to/file.cpp", "repo" }

        context "#path" do
          subject { context.path }
          it { should eq "path/to/file.cpp" }
        end

        context "#repo" do
          subject { context.repo }
          it { should eq "repo" }
        end

        context "move subdir/file.cpp" do

          before { context.move "subdir/file.cpp" }

          context "#path" do
            subject { context.path }
            it { should eq "path/to/subdir/file.cpp" }
          end

          context "#repo" do
            subject { context.repo }
            it { should eq "repo" }
          end

        end # move subdir/file.cpp

      end # move path/to/file.cpp, repo

      context "move subdir/file.cpp" do

        before { context.move "subdir/file.cpp" }

        context "#path" do
          subject { context.path }
          it { should eq "path/to/subdir/file.cpp" }
        end

        context "#repo" do
          subject { context.repo }
          it { should be_nil }
        end

      end # move subdir/file.cpp

    end # move file2.cpp

  end # move()

end # SocialSnippet::Context

