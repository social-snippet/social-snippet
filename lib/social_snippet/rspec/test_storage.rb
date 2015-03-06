RSpec.configure do

  shared_context :TestStorage do

    describe "test storage class" do

      let(:storage) { ::SocialSnippet::Storage.new }

      describe "#glob" do

        context "prepare storage" do

          before do
            storage.mkdir_p "/path/to/dir1"
            storage.mkdir_p "/path/to/dir2"
            storage.mkdir_p "/path/to/dir2/subdir1"
            storage.mkdir_p "/path/to/dir2/subdir2"
            storage.mkdir_p "/path/to/dir3"
            storage.touch "/path/to/file1.c"
            storage.touch "/path/to/dir1/file2.c"
            storage.touch "/path/to/dir1/file3.c"
            storage.touch "/path/to/dir2/file4.rb"
            storage.touch "/path/to/dir2/file5.c"
            storage.touch "/path/to/dir3/file6.cpp"
            storage.touch "/path/to/dir2/subdir1/file7.c"
            storage.touch "/path/to/dir2/subdir2/file8.rb"
          end

          context "glob /path/to/dir1" do
            subject { storage.glob "/path/to/dir1" }
            it { expect(subject.length).to eq 1 } 
            it { should include "/path/to/dir1" }
            it { should_not include "/path/to/dir2" }
            it { should_not include "/path/to/dir3" }
            it { should_not include "/path/to/file1.c" }
          end

          context "glob /path/to/*.c" do
            subject { storage.glob "/path/to/*.c" }
            it { expect(subject.length).to eq 1 } 
            it { should_not include "/path/to/" }
            it { should_not include "/path/to/dir2" }
            it { should_not include "/path/to/dir3" }
            it { should include "/path/to/file1.c" }
            it { should_not include "/path/to/dir1/file2.c" }
            it { should_not include "/path/to/dir1/file3.c" }
            it { should_not include "/path/to/dir2/file5.c" }
            it { should_not include "/path/to/dir3/file6.cpp" }
            it { should_not include "/path/to/dir2/subdir1/file7.c" }
          end

          context "glob /path/to/**/*.c" do
            subject { storage.glob "/path/to/**/*.c" }
            it { expect(subject.length).to eq 5 } 
            it { should_not include "/path/to/" }
            it { should_not include "/path/to/dir2" }
            it { should_not include "/path/to/dir3" }
            it { should include "/path/to/file1.c" }
            it { should include "/path/to/dir1/file2.c" }
            it { should include "/path/to/dir1/file3.c" }
            it { should include "/path/to/dir2/file5.c" }
            it { should_not include "/path/to/dir3/file6.cpp" }
            it { should include "/path/to/dir2/subdir1/file7.c" }
          end

          context "glob /path/to/dir2/**/*.c" do
            subject { storage.glob "/path/to/dir2/**/*.c" }
            it { expect(subject.length).to eq 2 } 
            it { should_not include "/path/to/" }
            it { should_not include "/path/to/dir2" }
            it { should_not include "/path/to/dir3" }
            it { should_not include "/path/to/file1.c" }
            it { should_not include "/path/to/dir1/file2.c" }
            it { should_not include "/path/to/dir1/file3.c" }
            it { should include "/path/to/dir2/file5.c" }
            it { should_not include "/path/to/dir3/file6.cpp" }
            it { should include "/path/to/dir2/subdir1/file7.c" }
          end

          context "glob /path/to/**/*.cpp" do
            subject { storage.glob "/path/to/**/*.cpp" }
            it { expect(subject.length).to eq 1 } 
            it { should_not include "/path/to/" }
            it { should_not include "/path/to/dir2" }
            it { should_not include "/path/to/dir3" }
            it { should_not include "/path/to/file1.c" }
            it { should_not include "/path/to/dir1/file2.c" }
            it { should_not include "/path/to/dir1/file3.c" }
            it { should_not include "/path/to/dir2/file5.c" }
            it { should include "/path/to/dir3/file6.cpp" }
            it { should_not include "/path/to/dir2/subdir1/file7.c" }
          end

          context "glob /path/to/**/*.rb" do
            subject { storage.glob "/path/to/**/*.rb" }
            it { expect(subject.length).to eq 2 } 
            it { should_not include "/path/to/" }
            it { should_not include "/path/to/dir2" }
            it { should_not include "/path/to/dir3" }
            it { should_not include "/path/to/file1.c" }
            it { should_not include "/path/to/dir1/file2.c" }
            it { should_not include "/path/to/dir1/file3.c" }
            it { should include "/path/to/dir2/file4.rb" }
            it { should_not include "/path/to/dir2/file5.c" }
            it { should_not include "/path/to/dir3/file6.cpp" }
            it { should_not include "/path/to/dir2/subdir1/file7.c" }
            it { should include "/path/to/dir2/subdir2/file8.rb" }
          end

          context "glob /path/to/dir2/**/*.rb" do
            subject { storage.glob "/path/to/dir2/**/*.rb" }
            it { expect(subject.length).to eq 2 } 
            it { should_not include "/path/to/" }
            it { should_not include "/path/to/dir2" }
            it { should_not include "/path/to/dir3" }
            it { should_not include "/path/to/file1.c" }
            it { should_not include "/path/to/dir1/file2.c" }
            it { should_not include "/path/to/dir1/file3.c" }
            it { should include "/path/to/dir2/file4.rb" }
            it { should_not include "/path/to/dir2/file5.c" }
            it { should_not include "/path/to/dir3/file6.cpp" }
            it { should_not include "/path/to/dir2/subdir1/file7.c" }
            it { should include "/path/to/dir2/subdir2/file8.rb" }
          end

        end

      end #glob

      context "mkdir_p /path/to" do

        before { storage.mkdir_p "/path/to" }

        context "exists? /path/to" do
          before { storage.exists? "/path/to" }
          it { should be_truthy }
        end

        context "file? /path/to" do
          subject { storage.file? "/path/to" }
          it { should be_falsey }
        end

        context "directory? /path/to" do
          subject { storage.directory? "/path/to" }
          it { should be_truthy }
        end

        context "write /path/to/file, data" do
          before { storage.write "/path/to/file", "data" }
          context "read /path/to/file" do
            subject { storage.read "/path/to/file" }
            it { should eq "data" }
          end
        end

        context "touch /path/to/file" do

          before { storage.touch "/path/to/file" }

          context "exists? /path/to/file" do
            subject { storage.exists? "/path/to/file" }
            it { should be_truthy }
          end

          context "file? /path/to/file" do
            subject { storage.file? "/path/to/file" }
            it { should be_truthy }
          end

          context "directory? /path/to/file" do
            subject { storage.directory? "/path/to/file" }
            it { should be_falsey }
          end

          context "rm_r /path/to" do

            before { storage.rm_r "/path/to" }

            context "exists? /path/to" do
              subject { storage.exists? "/path/to" }
              it { should be_falsey }
            end

            context "file? /path/to" do
              subject { storage.file? "/path/to" }
              it { should be_falsey }
            end

            context "directory? /path/to" do
              subject { storage.directory? "/path/to" }
              it { should be_falsey }
            end

            context "exists? /path/to/file" do
              subject { storage.exists? "/path/to/file" }
              it { should be_falsey }
            end

            context "file? /path/to/file" do
              subject { storage.file? "/path/to/file" }
              it { should be_falsey }
            end

            context "directory? /path/to/file" do
              subject { storage.directory? "/path/to/file" }
              it { should be_falsey }
            end

          end

          context "rm /path/to/file" do

            before { storage.rm "/path/to/file" }

            context "exists? /path/to/file" do
              subject { storage.exists? "/path/to/file" }
              it { should be_falsey }
            end

            context "file? /path/to/file" do
              subject { storage.file? "/path/to/file" }
              it { should be_falsey }
            end

            context "directory? /path/to/file" do
              subject { storage.directory? "/path/to/file" }
              it { should be_falsey }
            end

          end # rm /path/to/file

        end # touch /path/to/file

      end # mkdir_p /path/to

    end # test storage class

  end # [shared] TestStorage

end
