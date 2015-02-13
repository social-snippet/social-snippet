module SocialSnippet

  class Resolvers::InsertResolver < Resolvers::BaseResolver

    attr_reader :deps_resolver
    attr_reader :options

    # Constructor
    #
    # @param social_snippet [::SocialSnippet::Core]
    def initialize(social_snippet, new_options = {})
      @options = new_options
      @deps_resolver = Resolvers::DepResolver.new(social_snippet)
      super(social_snippet)
      init_options
    end

    def init_options
      options[:margin_bottom] = options.fetch(:margin_bottom, 0)
      options[:margin_top] = options.fetch(:margin_top, 0)
    end

    # Insert snippets to given text
    #
    # @param text [String] The text of source code
    def insert(text)
      raise "must be passed string" unless text.is_a?(String)

      context = Context.new("")
      snippet = Snippet.new_text(text)

      snippet.snippet_tags.each do |tag_info|
        visit tag_info[:tag]
      end

      dest = insert_func(snippet, context)
      return dest.join($/)
    end

    private

    def insert_func(snippet, context_from, base_tag = nil)
      raise "must be passed snippet" unless snippet.is_a?(Snippet)

      inserter = Inserter.new(snippet.lines)
      context = context_from.clone

      # replace each @snip tags
      each_snip_tags(snippet, context, base_tag) do |tag, line_no, next_snippet, new_context|
        inserter.set_index line_no
        inserter.ignore

        visit(tag) if is_self(tag, context)
        next if is_visited(tag)

        insert_depended_snippets! inserter, next_snippet, new_context, tag
        insert_by_tag_and_context! inserter, next_snippet, new_context, tag
      end

      inserter.set_index_last
      return inserter.dest
    end

    # Insert snippet by tag and context
    def insert_by_tag_and_context!(inserter, snippet, context, tag)
      raise "must be passed snippet" unless snippet.is_a?(Snippet)

      src = insert_func(snippet, context, tag)

      options[:margin_top].times { inserter.insert "" }
      inserter.insert tag.to_snippet_tag # @snip -> @snippet
      inserter.insert src
      options[:margin_bottom].times { inserter.insert "" }

      visit tag
    end

    # Insert depended snippet
    def insert_depended_snippets!(inserter, snippet, context, tag)
      raise "must be passed snippet" unless snippet.is_a?(Snippet)

      dep_tags = deps_resolver.find(snippet, context, tag)
      dep_tags = sort_dep_tags_by_dep(dep_tags)

      dep_tags.each do |tag_info|
        sub_t = tag_info[:tag]
        sub_c = tag_info[:context]

        visit(tag) if is_self(tag, context)
        next if is_visited(sub_t)

        next_snippet = social_snippet.repo_manager.get_snippet(sub_c, sub_t)
        insert_by_tag_and_context! inserter, next_snippet, sub_c, sub_t
      end
    end

    # Sort by dependency
    def sort_dep_tags_by_dep(dep_tags)
      dep_tags_index = {}

      # map tag to index
      dep_tags.each.with_index do |tag_info, k|
        tag = tag_info[:tag]
        dep_tags_index[tag.to_path] = k
      end

      # generate dependency graph
      dep_tags_hash = TSortableHash.new
      dep_tags.each do |tag_info|
        tag = tag_info[:tag].to_path
        dep_ind = dep_tags_index[tag]
        dep_tags_hash[dep_ind] = deps_resolver.dep_to[tag].to_a.map {|tag| dep_tags_index[tag] }
      end

      dep_tags_hash.tsort.map {|k| dep_tags[k]}
    end

  end # BaseResolver

end # SocialSnippet
