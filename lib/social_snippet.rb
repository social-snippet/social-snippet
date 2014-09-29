require_relative "social_snippet/version"
require_relative "social_snippet/tag"
require_relative "social_snippet/tag_parser"
require_relative "social_snippet/config"
require_relative "social_snippet/repository"
require_relative "social_snippet/repository_manager"
require_relative "social_snippet/context"
require_relative "social_snippet/snippet"
require_relative "social_snippet/inserter"
require_relative "social_snippet/snippet_finder"

require "rugged"
require "version_sorter"
require "tsort"

# Extend Hash tsortable
class Hash
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

module SocialSnippet

  class SocialSnippet
    attr_reader :repo_manager

    # Constructor
    def initialize
      @config = Config.new.freeze
      init_repo
    end

    # Initialize for repository
    def init_repo
      @repo_manager = RepositoryManager.new(@config)
    end

    # Insert snippets to given text
    #
    # @param src [String] The text of source code
    def insert_snippet(src)
      searcher = SnippetFinder::SnippetFinderWithInsert.new(repo_manager)
      return searcher.insert(src)
    end

  end
end

