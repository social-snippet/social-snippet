require "spec_helper"

module SocialSnippet

  describe Api::InsertSnippetApi do

    describe "#insert_snippet()", :without_fakefs => true do

      let(:example_repo_info) do
        {
          "name" => "example-repo",
          "desc" => "This is my repository.",
          "url" => "https://github.com/social-snippet/example-repo",
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
            
            # last update: 2014-10-28
            it { expect(string_io.string).to match(/@snippet/) }
            it { expect(string_io.string).to match(/example-repo#.*:func\.cpp/) }
            it { expect(string_io.string).to match(/example-repo#.*:func\/sub_func_1\.cpp/) }
            it { expect(string_io.string).to match(/example-repo#.*:func\/sub_func_2\.cpp/) }
            it { expect(string_io.string).to match(/example-repo#.*:func\/sub_func_3\.cpp/) }

          end # $ ssnip / with a snip tag

        end # create instance

      end # $ sspm install example-repo

    end # insert_snippet()

  end # Api

end # SocialSnippet::CommandLine

