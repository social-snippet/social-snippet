module SocialSnippet

  module CommandLine

    module Sspm

      module SubCommands

        class SearchCommand < Command

          attr_reader :query
          attr_reader :client

          def initialize(new_args)
            super

            @query = args.find {|arg| is_not_line_option? arg }

            @client = ::SocialSnippet::RegistryClient.new(
              SSPM_API_HOST,
              SSPM_API_VERSION,
              SSPM_API_PROTOCOL,
            )
          end

          def define_options
            # show name
            opt_parser.on "-n", "--[no-]name" do |v|
              options[:show_name] = v
            end

            # show desc
            opt_parser.on "-d", "--[no-]desc" do |v|
              options[:show_desc] = v
            end

            # show url
            opt_parser.on "-u", "--[no-]url" do |v|
              options[:show_url] = v
            end
          end

          def set_default_options
            options[:show_name] = true if options[:show_name].nil?
            options[:show_desc] = true if options[:show_desc].nil?
            options[:show_url]  = false if options[:show_url].nil?
          end

          def run
            client.get_repositories(query).each do |repo|
              puts output_format % output_list(repo)
            end
          end

          private

          def output_format
            f = ""
            if options[:show_name]
              f += "%s"
            end
            if options[:show_desc]
              if options[:show_name]
                f += ": "
              end
              f += "%s"
            end
            if options[:show_url]
              if options[:show_name] && options[:show_desc]
                f += " (%s)"
              elsif options[:show_name]
                f += ": %s"
              elsif options[:show_desc]
                f += " (%s)"
              else
                f += "%s"
              end
            end
            return f
          end

          def output_list(repo)
            list = []
            list.push repo["name"] if options[:show_name]
            list.push repo["desc"] if options[:show_desc]
            list.push repo["url"] if options[:show_url]
            return list
          end

        end

      end

    end

  end

end
