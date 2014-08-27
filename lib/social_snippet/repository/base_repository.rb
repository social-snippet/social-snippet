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
    end
  end
end
