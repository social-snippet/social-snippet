module SocialSnippet

  class Resolvers::DepResolver < Resolvers::BaseResolver

    attr_reader :dep_to

    # Constructor
    #
    # @param social_snippet [::SocialSnippet::Core]
    def initialize(social_snippet)
      @dep_to = {} # dep_to[tag_from] = tag_to
      super(social_snippet)
    end

    # Find all missing depended snippets
    #
    # @param snippet [Snippet] The text of source code
    # @param context_from [SocialSnippet::Context] The context of previous code
    # @param tag_from [SocialSnippet::Tag] The previous tag
    def find(snippet, context_from, tag_from)
      raise "must be passed snippet" unless snippet.is_a?(Snippet)

      found_tags = find_func(snippet, context_from, tag_from)
      found_tags.each do |tag_info|
        # remove self from deps graph
        tag = tag_info[:tag]
        dep_to[tag.to_path] ||= ::Set.new
        dep_to[tag.to_path].delete tag_from.to_path
      end
      found_tags
    end

    private

    def set_snippet_dep(tag_from, tag_to)
      dep_to[tag_from.to_path] ||= ::Set.new
      dep_to[tag_from.to_path].add tag_to.to_path
    end

    def find_func(snippet, context_from, tag_from)
      raise "must be passed snippet" unless snippet.is_a?(Snippet)

      found_tags = []
      context = context_from.clone

      each_child_snippet(snippet, context_from, tag_from) do |tag, line_no, child_snippet, new_context|
        next if is_visited(tag)
        visit tag

        set_snippet_dep tag_from, tag
        found_tags.push({
          :tag => tag,
          :context => new_context,
        })
        found_tags.push *find_func(child_snippet, new_context, tag)
      end

      return found_tags
    end

  end # DepResolver

end # SocialSnippet

