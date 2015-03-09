require "spec_helper"

describe ::SocialSnippet::StorageBackend::FileSystemStorage do

  let(:storage) { ::SocialSnippet::StorageBackend::FileSystemStorage.new }

  include_context :TestStorage

  context "test storage class" do

    describe "#read" do

      context "read path/to/file" do

        example do
          expect { storage.read "path/to/file" }.to raise_error ::Errno::ENOENT
        end
        context "prepare path/to/file" do

          before do
            ::FileUtils.mkdir_p "path/to"
            ::FileUtils.touch "path/to/file"
          end

          context "read path/to/file" do
            example do
              expect { storage.read "path/to/file" }.to_not raise_error
            end
          end

        end # prepare path/to/file

      end # read path/to/file

    end #read

    describe "#write" do

      context "write path/to/file" do
        before do
          ::FileUtils.mkdir_p "path/to"
          storage.write "path/to/file", "data-123"
        end
        context "::File.read path/to/file" do
          subject { ::File.read "path/to/file" }
          it { should eq "data-123" }
        end
      end

    end #write

    describe "#glob" do

      context "glob path/to/*" do
        subject { storage.glob "path/to/*" }
        it { should be_empty }

        context "prepare files" do

          before do
            ::FileUtils.mkdir_p "path/to"
            ::FileUtils.touch "path/to/file1"
            ::FileUtils.touch "path/to/file2"
            ::FileUtils.touch "path/to/file3"
            ::FileUtils.mkdir_p "path/to/directory"
          end

          context "glob path/to/*" do
            subject { storage.glob "path/to/*" }
            it { should_not be_empty }
            it { should include /path\/to\/file1$/ }
            it { should include /path\/to\/directory$/ }
          end

          context "glob path/to/f*" do
            subject { storage.glob "path/to/f*" }
            it { should_not be_empty }
            it { should include /path\/to\/file1$/ }
            it { should_not include /path\/to\/directory$/ }
          end

          context "glob path/to/not_found*" do
            subject { storage.glob "path/to/not_found*" }
            it { should be_empty }
            it { should_not include /path\/to\/file1$/ }
            it { should_not include /path\/to\/directory$/ }
          end

          context "glob path/to/file1" do
            subject { storage.glob "path/to/file1" }
            it { should_not be_empty }
            it { should include /path\/to\/file1$/ }
            it { should_not include /path\/to\/file2$/ }
            it { should_not include /path\/to\/file3$/ }
            it { should_not include /path\/to\/directory$/ }
          end

        end

      end

    end #glob

    describe "#exists?" do

      context "prepare files" do

        before do
          ::FileUtils.mkdir_p "path/to"
          ::FileUtils.touch "path/to/file1"
          ::FileUtils.touch "path/to/file2"
          ::FileUtils.touch "path/to/file3"
          ::FileUtils.mkdir_p "path/to/dir"
        end

        it { expect(storage.exists? "path/to/file1").to be_truthy }
        it { expect(storage.exists? "path/to/file2").to be_truthy }
        it { expect(storage.exists? "path/to/file3").to be_truthy }
        it { expect(storage.exists? "path/to/dir").to be_truthy }

      end

    end #exists?

    describe "#file?" do

      context "prepare files" do

        before do
          ::FileUtils.mkdir_p "path/to"
          ::FileUtils.touch "path/to/file1"
          ::FileUtils.touch "path/to/file2"
          ::FileUtils.touch "path/to/file3"
          ::FileUtils.mkdir_p "path/to/dir"
        end

        it { expect(storage.file? "path/to/file1").to be_truthy }
        it { expect(storage.file? "path/to/file2").to be_truthy }
        it { expect(storage.file? "path/to/file3").to be_truthy }
        it { expect(storage.file? "path/to/dir").to be_falsey }

      end

    end #file?

    describe "#directory?" do

      context "prepare files" do

        before do
          ::FileUtils.mkdir_p "path/to"
          ::FileUtils.touch "path/to/file1"
          ::FileUtils.touch "path/to/file2"
          ::FileUtils.touch "path/to/file3"
          ::FileUtils.mkdir_p "path/to/dir"
        end

        it { expect(storage.directory? "path/to/file1").to be_falsey }
        it { expect(storage.directory? "path/to/file2").to be_falsey }
        it { expect(storage.directory? "path/to/file3").to be_falsey }
        it { expect(storage.directory? "path/to/dir").to be_truthy }

      end

    end #directory?

  end # test storage class

end # ::SocialSnippet::StorageBackend::FileSystemStorage

