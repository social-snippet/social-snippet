require "spec_helper"

module SocialSnippet::CommandLine

  describe SSnip::MainCommand, :current => true, :use_raw_filesystem => true do

    before do
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_HOST", "api.server"
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_VERSION", "dummy"
      stub_const "SocialSnippet::CommandLine::Sspm::SSPM_API_PROTOCOL", "http"
    end # define constants

    before do
      FileUtils.mkdir_p "/tmp/social-snippet"
      tmp_path = Dir.mktmpdir(nil, "/tmp/social-snippet")
      ENV["SOCIAL_SNIPPET_HOME"] = tmp_path
    end # prepare tmp dir

    let(:result) do
      [
        {
          "name" => "example-repo",
          "desc" => "This is my repository.",
          "url" => "https://github.com/social-snippet/example-repo",
        },
      ]
    end # result

    before do
      WebMock
      .stub_request(
        :get,
        "http://api.server/api/dummy/repositories/example-repo/dependencies",
      )
      .to_return(
        :status => 200,
        :body => result.to_json,
        :headers => {
          "Content-Type" => "application/json",
        },
      )
    end # GET /repositories/my-repo/dependencies

    context "$ sspm install example-repo" do

      before do
        cli = Sspm::SubCommands::InstallCommand.new ["example-repo"]
        cli.init
        expect { cli.run }.to output(/Success/).to_stdout
      end

      context "create instance" do

        context "$ ssnip / without snip" do

          let(:input) do
            [
              'hello',
              'world',
            ].join("\n")
          end

          let(:expected) do
            [
              'hello',
              'world',
            ].join("\n") + "\n"
          end

          let(:cli) do
            SSnip::MainCommand.new [], input
          end

          before do
            cli.init
          end

          it do
            expect { cli.run }.to output(expected).to_stdout
          end

        end # $ ssnip / without snip

        context "$ ssnip / with a snip tag" do

          let(:input) do
            [
              '// @snip <example-repo:func.cpp>'
            ].join("\n")
          end

          let(:cli) do
            SSnip::MainCommand.new [], input
          end

          before do
            cli.init
          end

          context "check output" do
            # last update: 2014/10/28
            it { expect { cli.run }.to output(/@snippet/).to_stdout }
            it { expect { cli.run }.to output(/example-repo#.*:func\.cpp/).to_stdout }
            it { expect { cli.run }.to output(/example-repo#.*:func\/sub_func_1\.cpp/).to_stdout }
            it { expect { cli.run }.to output(/example-repo#.*:func\/sub_func_2\.cpp/).to_stdout }
            it { expect { cli.run }.to output(/example-repo#.*:func\/sub_func_3\.cpp/).to_stdout }
          end

        end # $ ssnip / with a snip tag

      end # create instance

    end # $ sspm install example-repo

  end # SSnip::MainCommand

end # SocialSnippet::CommandLine

