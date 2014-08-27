module SocialSnippet
  module Repository
    # Repository base class
    # usage: class GitRepository < BaseRepository
    class BaseRepository
      attr_reader :path
      attr_reader :cache_path
      attr_reader :name
      attr_reader :desc
      attr_reader :main

      # Constructor
      def initialize(path)
        @path = path
        @cache_path = nil
      end

      # Load snippet.json file
      def load_snippet_json()
        text = File.read("#{@path}/snippet.json")
        snippet_json = JSON.parse(text)
        @name = snippet_json["name"]
        @desc = snippet_json["desc"]
        @main = snippet_json["main"] || ""
      end

      # Get current ref's commit id
      def get_commit_id()
        raise "not implement get_commit_id()"
      end

      # Checkout to ref
      def checkout(ref)
        raise "not implement checkout()"
      end

      class << self
        # Check given text is version string
        def is_version(s)
          return /^([0]|[1-9][0-9]*)\.([0]|[1-9][0-9]*)\.([0]|[1-9][0-9]*)$/ === s
        end
      end
    end
  end
end
