RSpec.configure do

  shared_context :TestStorage do

    describe "test storage class" do

      let(:storage) { ::SocialSnippet::Storage.new }

      describe "#directory?" do

        context "mkdir dir" do

          before { storage.mkdir_p "dir" }

          context "directory? dir" do
            subject { storage.directory? "dir" }
            it { should be_truthy }
          end

          context "directory? dir/" do
            subject { storage.directory? "dir/" }
            it { should be_truthy }
          end

          context "file? dir" do
            subject { storage.file? "dir" }
            it { should be_falsey }
          end

          context "file? dir/" do
            subject { storage.file? "dir/" }
            it { should be_falsey }
          end

          context "write dir/file.txt" do
            before { storage.write "dir/file.txt", "" }
            context "directory? dir" do
              subject { storage.directory? "dir" }
              it { should be_truthy }
            end
            context "directory? dir/" do
              subject { storage.directory? "dir/" }
              it { should be_truthy }
            end
            context "file? dir" do
              subject { storage.file? "dir" }
              it { should be_falsey }
            end
            context "file? dir/" do
              subject { storage.file? "dir/" }
              it { should be_falsey }
            end
            context "file? dir/file.txt" do
              subject { storage.file? "dir/file.txt" }
              it { should be_truthy }
            end
            context "directory? dir/file.txt" do
              subject { storage.directory? "dir/file.txt" }
              it { should be_falsey }
            end
          end
        end

      end #directory?

      describe "no entry" do

        context "read not_found.txt" do
          subject do
            lambda { storage.read "not_found.txt" }
          end
          it { should raise_error ::Errno::ENOENT }
        end

        context "rm path/to/not_found" do
          subject do
            lambda { storage.rm "path/to/not_found.txt" }
          end
          it { should raise_error ::Errno::ENOENT }
        end

        context "touch not_found/path/to/file" do
          subject do
            lambda { storage.touch "not_found/path/to/file" }
          end
          it { should raise_error ::Errno::ENOENT }
        end

        context "rm_r path/to/not_found" do
          subject do
            lambda { storage.rm_r "path/to/not_found" }
          end
          it { should raise_error ::Errno::ENOENT }
        end

        context "cd path/to/not_found" do
          subject do
            lambda { storage.cd "path/to/not_found" }
          end
          it { should raise_error ::Errno::ENOENT }
        end

        context "prepare file" do
          before do
            storage.mkdir_p "path/to"
            storage.touch "path/to/file"
          end
          context "cd path/to/file" do
            subject do
              lambda { storage.cd "path/to/file"; p storage.pwd; p storage.file?(storage.pwd) }
            end
            # TODO: it { should raise_error ::Errno::ENOTDIR }
          end
        end

      end # no entry

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

      describe "change workdir" do

        let!(:root_dir) { storage.pwd }

        context "mkdir path/to/dir" do

          subject { storage.pwd }

          before { storage.mkdir_p "path/to/dir" }

          context "cd path/to" do

            before { storage.cd "path/to" }
            it { should eq ::File.join(root_dir, "path", "to") }

            context "cd ../" do

              before { storage.cd "../" }
              it { should eq ::File.join(root_dir, "path") }

              context "storage.cd ./" do

                before { storage.cd "./" }
                it { should eq ::File.join(root_dir, "path") }

                context "storage.cd ./to/dir" do
                  before { storage.cd "to/dir" }
                  it { should eq ::File.join(root_dir, "path", "to", "dir") }
                end

              end

            end

          end

          context "touch path/to/dir/file" do
            before { storage.touch "path/to/dir/file" }
            context "cd path/to/dir" do
              before { storage.cd "path/to/dir" }
              context "read file" do
                subject { storage.file? "file" }
                it { should be_truthy }
              end
              context "read file from root" do
                before { storage.cd root_dir }
                subject { storage.file? "path/to/dir/file" }
                it { should be_truthy }
              end
            end
          end

        end # mkdir path/to/dir

        context "mkdir path" do

          before { storage.mkdir "path" }

          context "cd path" do

            before { storage.cd "path" }

            context "mkdir to" do

              before { storage.mkdir "to" }

              context "cd to" do

                before { storage.cd "to" }

                context "mkdir dir" do

                  before { storage.mkdir "dir" }

                  context "cd root" do

                    before { storage.cd root_dir }

                    context "directory? path/to/dir" do
                      subject { storage.directory? "path/to/dir" }
                      it { should be_truthy }
                    end

                  end

                end

                context "write file, data" do

                  before { storage.write "file", "data" }

                  context "cd root" do

                    before { storage.cd root_dir }

                    context "read path/to/file" do
                      subject { storage.read "path/to/file" }
                      it { should eq "data" }
                    end

                  end

                end

              end

            end

          end

        end

      end # change workdir

      describe "duplication" do

        context "mkdir /lib" do

          before { storage.mkdir "/lib" }

          context "touch /lib/entity" do

            before { storage.touch "/lib/entity" }

            context "mkdir /lib/entity" do

              subject do
                lambda { storage.mkdir "/lib/entity" }
              end

              it { should raise_error ::Errno::EEXIST }

            end

          end

          context "mkdir /lib/entity" do

            before { storage.mkdir "/lib/entity" } 

            context "touch /lib/entity" do

              subject do
                lambda { storage.touch "/lib/entity" }
              end

              it { should_not raise_error }

            end

            context "write /lib/entity, data" do

              subject do
                lambda { storage.write "/lib/entity", "data" }
              end

              it { should raise_error ::Errno::EISDIR }

            end

          end

        end # mkdir /lib

      end # duplication

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
