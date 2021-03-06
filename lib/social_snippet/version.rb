module SocialSnippet

  VERSION = "0.0.14"

  module Version

    class << self

      # Check given text matches version pattern
      def is_matched_version_pattern(pattern, version)
        return true if pattern == "" || pattern.nil?
        return true if pattern == version

        # "2.1.0" and "2.1.1" match "2.1"
        # "2.11.0" and "2.11.1" do not match "2.1"
        version.start_with?("#{pattern}.")
      end

      # Check given text is version string
      def is_version(s)
        /^([0]|[1-9][0-9]*)\.([0]|[1-9][0-9]*)\.([0]|[1-9][0-9]*)$/ === s
      end

      # "1.2.3" => "1.2"
      def minor(s)
        /^(([0]|[1-9][0-9]*)\.([0]|[1-9][0-9]*))\.([0]|[1-9][0-9]*)$/.match(s)[1]
      end

    end

  end

end
