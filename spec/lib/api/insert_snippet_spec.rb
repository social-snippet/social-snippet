require "spec_helper"

module SocialSnippet

  describe Api::InsertSnippetApi do

    describe "#insert_snippet()", :without_fakefs => true do

      class FakeDriver < ::SocialSnippet::Repository::Drivers::DriverBase
        def fetch; end

        def refs
          [
            "master",
            "develop",
            "1.0.0",
            "1.0.1",
            "1.0.2",
          ]
        end

        def snippet_json
          {
            "name" => "example-repo",
            "main" => "src",
          }
        end

        def rev_hash(ref)
          raise "error" unless refs.include?(ref)
          "rev-#{ref}"
        end

        def each_directory(ref, &block)
          [
            ::SocialSnippet::Repository::Drivers::Entry.new("src", ""),
            ::SocialSnippet::Repository::Drivers::Entry.new("src/func", ""),
          ].each &block
        end

        def each_file(ref, &block)
          files = []

          # snippet.json
          files.push ::SocialSnippet::Repository::Drivers::Entry.new "snippet.json", [
            '{',
            '  "name": "example-repo",',
            '  "desc": "This is an example repository.",',
            '  "language": "C++",',
            '  "main": "src"',
            '}',
          ].join($/)

          # src/func.cpp
          files.push ::SocialSnippet::Repository::Drivers::Entry.new "src/func.cpp", [
            '// @snip<func/sub_func_1.cpp>',
            '// @snip<func/sub_func_2.cpp>',
            '// @snip<func/sub_func_3.cpp>',
            'int func() {',
            '  int res = 0;',
            '  res += sub_func_1();',
            '  res += sub_func_2();',
            '  res += sub_func_3();',
            '  res *= 2;',
            '  return res;',
            '}',
          ].join($/)

          # src/func/sub_func_1.cpp
          files.push ::SocialSnippet::Repository::Drivers::Entry.new "src/func/sub_func_1.cpp", [
            'int sub_func_1() {',
            '  return 1;',
            '}',
          ].join($/)

          # src/func/sub_func_2.cpp
          files.push ::SocialSnippet::Repository::Drivers::Entry.new "src/func/sub_func_2.cpp", [
            'int sub_func_2() {',
            '  return 2;',
            '}',
          ].join($/)

          # src/func/sub_func_3.cpp
          files.push ::SocialSnippet::Repository::Drivers::Entry.new "src/func/sub_func_3.cpp", [
            'int sub_func_4() {',
            '  return 3;',
            '}',
          ].join($/)

          files.each &block
        end

        def self.target_url?(url)
          "dummy" === ::URI.parse(url).scheme
        end
      end

      before do
        fake_core.repo_factory.add_driver FakeDriver
      end

      let(:example_repo_info) do
        {
          "name" => "example-repo",
          "desc" => "This is my repository.",
          "url" => "dummy://driver.test/social-snippet/example-repo",
          "dependencies" => {
          },
        }
      end # example_repo_info

      before do
        WebMock
        .stub_request(
          :get,
          "https://api.server/api/v0/repositories/example-repo",
        )
        .to_return(
          :status => 200,
          :body => example_repo_info.to_json,
          :headers => {
            "Content-Type" => "application/json",
          },
        )
      end # GET /repositories/my-repo

      context "$ sspm install example-repo" do

        let(:install_command) { CommandLine::SSpm::SubCommands::InstallCommand.new ["example-repo"] }
        let(:install_command_output) { ::StringIO.new }
        let(:install_command_logger) { ::SocialSnippet::Logger.new install_command_output }

        before do
          allow(fake_core).to receive(:logger).and_return install_command_logger
          install_command.init
          install_command.run
          expect(install_command_output.string).to match /Success/
        end # install example-repo

        context "create instance" do

          let(:string_io) { ::StringIO.new }
          let(:string_logger) { ::SocialSnippet::Logger.new(string_io) }
          before { allow(fake_core).to receive(:logger).and_return string_logger }

          #
          # tests from here
          #

          context "insert a plain text" do

            let(:input) do
              [
                'hello',
                'world',
              ].join($/)
            end

            let(:expected) do
              [
                'hello',
                'world',
              ].join($/) + $/
            end

            before { fake_core.api.insert_snippet input }
            it { expect(string_io.string).to eq expected }

          end # $ ssnip / without snip

          context "$ ssnip / with a snip tag" do

            let(:input) do
              [
                '// @snip <example-repo:func.cpp>'
              ].join($/)
            end

            before { fake_core.api.insert_snippet input }
            
            it { expect(string_io.string).to match(/@snippet/) }
            it { expect(string_io.string).to match(/example-repo#.*:func\.cpp/) }
            it { expect(string_io.string).to match(/example-repo#.*:func\/sub_func_1\.cpp/) }
            it { expect(string_io.string).to match(/example-repo#.*:func\/sub_func_2\.cpp/) }
            it { expect(string_io.string).to match(/example-repo#.*:func\/sub_func_3\.cpp/) }
            it { expect(string_io.string).to_not match(/ERROR/) }

          end # $ ssnip / with a snip tag

        end # create instance

      end # $ sspm install example-repo

    end # insert_snippet()

  end # Api

end # SocialSnippet::CommandLine

