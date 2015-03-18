RSpec.configure do

  # need to set let(:driver_class) { ... }
  shared_context :TestDriver do

    describe "test driver class", :without_fakefs => true do

      context "handle github repo" do

        let(:repo_url) { "git://github.com/social-snippet/example-repo.git" }

        subject(:driver) do
          driver_class.new repo_url
        end

        context "driver.fetch" do

          before { driver.fetch }

          describe "#snippet_json" do

            context "driver.snippet_json" do
              subject { driver.snippet_json }
              it { should include "name" => "example-repo" }
            end

          end

          describe "#each_file" do
            context "get files" do
              let(:files) { ::Hash.new }
              before do
                driver.each_file("1.0.2") do |file|
                  files[file.path] = file.data
                end
              end
              subject { files }
              it { should include "README.md" }
              it { should include "snippet.json" }
              it { should include "src/func.cpp" }
              it { should include "src/func/sub_func_1.cpp" }
              it { should include "src/func/sub_func_2.cpp" }
              it { should include "src/func/sub_func_3.cpp" }
              it { expect(files["snippet.json"]).to match "example-repo" }
              it { expect(files["src/func/sub_func_1.cpp"]).to match "int sub_func_1()" }
            end
          end

          describe "#each_directory" do
            context "find directories" do
              let(:directories) { ::Array.new }
              before do
                driver.each_directory("1.0.2") do |dir|
                  directories.push dir.path
                end
              end
              subject { directories }
              it { should include "src" }
              it { should include "src/func" }
              it { should_not include "README.md" }
              it { should_not include "snippet.json" }
              it { should_not include "src/func.cpp" }
              it { should_not include "src/func/sub_func_1.cpp" }
              it { should_not include "src/func/sub_func_2.cpp" }
              it { should_not include "src/func/sub_func_3.cpp" }
            end
          end

          describe "#refs" do
            subject { driver.refs }
            it { should include "master" }
            it { should include "1.0.0" }
            it { should include "1.0.1" }
          end #refs

          describe "#versions" do
            subject { driver.versions }
            it { should_not include "master" }
            it { should include "1.0.0" }
            it { should include "1.0.1" }
          end #versions

          describe "#latest_version" do
            context "latest_version 1.0" do
              subject { driver.latest_version("1.0") }
              it { should eq "1.0.2" }
            end
            context "latest_version 9.9" do
              subject { driver.latest_version("9.9") }
              it { should eq nil }
            end
          end #latest_version

        end # driver.fetch

      end # github repo

    end # 

  end # [shared] TestDriver

end

