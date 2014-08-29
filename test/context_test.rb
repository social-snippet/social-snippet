require "spec_helper"

describe SocialSnippet::Context do

  describe ".new()" do

    context "pass absolute path" do

      let(:instance) { SocialSnippet::Context.new("/path/to/file.cpp") }

      context "move file2.cpp" do
        before { instance.move "file2.cpp" }
        it { expect(instance.path).to eq "/path/to/file2.cpp" }
      end

      context "move subdir/file3.cpp" do
        before { instance.move "subdir/file3.cpp" }
        it { expect(instance.path).to eq "/path/to/subdir/file3.cpp" }
      end

      context "move /path/to_another/file.cpp" do
        before { instance.move "/path/to_another/file.cpp" }
        it { expect(instance.path).to eq "/path/to_another/file.cpp" }
      end

    end # pass absolute path

  end # .new()

end # SocialSnippet::Context

