require "spec_helper"

describe SocialSnippet::Context do

  describe "#move" do

    context "start from path/to/file1.cpp" do

      let(:context) { SocialSnippet::Context.new("path/to/file1.cpp") }
      it { expect(context.path).to eq "path/to/file1.cpp" }
      it { expect(context.dirname).to eq "path/to" }
      it { expect(context.repo).to be_nil }

      context "move into ./file2.cpp" do

        before { context.move "./file2.cpp" }
        it { expect(context.path).to eq "path/to/file2.cpp" }
        it { expect(context.dirname).to eq "path/to" }
        it { expect(context.repo).to be_nil }

        context "move into subdir/file3.cpp" do

          before { context.move "subdir/file3.cpp" }
          it { expect(context.path).to eq "path/to/subdir/file3.cpp" }
          it { expect(context.dirname).to eq "path/to/subdir" }
          it { expect(context.repo).to be_nil }

        end # move into subdir/file3.cpp

        context "move into path/to/repo/file4.cpp at repo" do

          before { context.move "path/to/repo/file4.cpp", "repo" }
          it { expect(context.path).to eq "path/to/repo/file4.cpp" }
          it { expect(context.dirname).to eq "path/to/repo" }
          it { expect(context.repo).to eq "repo" }

          context "move into subdir/file5.cpp" do

            before { context.move "subdir/file5.cpp" }
            it { expect(context.path).to eq "path/to/repo/subdir/file5.cpp" }
            it { expect(context.dirname).to eq "path/to/repo/subdir" }
            it { expect(context.repo).to eq "repo" }

          end # move into subdir/file5.cpp

        end # move into path/to/reop/file3.cpp at repo

      end # move into file2.cpp

    end # start from path/to/file1.cpp

  end # move

end # SocialSnippet::Context

