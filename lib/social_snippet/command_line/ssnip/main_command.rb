module SocialSnippet::CommandLine

  class SSnip::MainCommand < Command

    attr_reader :sub_commands

    def usage
      <<EOF
Usage: ssnip [options]

Example:
    $ cat target_file | ssnip > snipped_file

EOF
    end

    def define_options
    end

    def run
      core.api.insert_snippet(input_stream.read)
    end

  end

end
