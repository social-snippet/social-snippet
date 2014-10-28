module SocialSnippet

  module CommandLine

    module SSnip

      class MainCommand < Command

        attr_reader :sub_commands
        attr_reader :social_snippet

        def initialize(new_args, input = "")
          super
          @social_snippet = SocialSnippet.new
        end

        def define_options
        end

        def set_default_options
        end

        def run
          puts social_snippet.insert_snippet(input)
        end

      end

    end

  end

end
