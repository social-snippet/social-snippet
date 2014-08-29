require "spec_helper"

describe SocialSnippet::Context do

  let(:context) { SocialSnippet::Context.new("path/to/file.cpp") }

  describe "#move" do

    context "move ./file2.cpp" do

      before { context.move "./file2.cpp" }

      it { expect(context.path).to eq "path/to/file2.cpp" }
      it { expect(context.repo).to be_nil }

      context "move path/to/file.cpp, repo" do

        before { context.move "path/to/file.cpp", "repo" }

        it { expect(context.path).to eq "path/to/file.cpp" }
        it { expect(context.repo).to eq "repo" }

        context "move subdir/file.cpp" do

          before { context.move "subdir/file.cpp" }

          it { expect(context.path).to eq "path/to/subdir/file.cpp" }
          it { expect(context.repo).to eq "repo" }

        end # move subdir/file.cpp

      end # move path/to/file.cpp, repo

      context "move subdir/file.cpp" do

        before { context.move "subdir/file.cpp" }

        it { expect(context.path).to eq "path/to/subdir/file.cpp" }
        it { expect(context.repo).to be_nil }

      end # move subdir/file.cpp

    end # move file2.cpp

  end # move

end # SocialSnippet::Context

