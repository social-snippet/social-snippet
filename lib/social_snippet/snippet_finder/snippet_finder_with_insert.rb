module SocialSnippet
  module SnippetFinder
    class SnippetFinderWithInsert < SnippetFinderBase
      attr_reader :dep_searcher

      # Constructor
      #
      # @param repo_manager [SocialSnippet::RepositoryManager]
      def initialize(repo_manager)
        @dep_searcher = SnippetFinderWithDep.new(repo_manager)
        super(repo_manager)
      end

      # Insert snippets to given text
      #
      # @param src [Array<String>] The text of source code
      def insert(src)
        context = Context.new("")
        lines = src.split("\n")

        TagParser.find_snippet_tags(lines).each do |tag_info|
          visit tag_info[:tag]
        end

        dest = insert_func(lines, context)
        return dest.join("\n")
      end

      private

      def insert_func(code, context_from, base_tag = nil)
        inserter = Inserter.new(code)
        context = context_from.clone

        # replace each @snip tags
        each_snip_tags(code, context, base_tag) do |tag, line_no, snippet, new_context|
          inserter.set_index line_no

          if is_visited(tag)
            inserter.remove
            next
          end

          inserter.remove
          insert_depended_snippets! inserter, snippet, new_context, tag
          insert_by_tag_and_context! inserter, snippet, new_context, tag
        end

        return inserter.dest
      end

      # Insert snippet by tag and context
      def insert_by_tag_and_context!(inserter, snippet, context, tag)
        src = insert_func(snippet.lines, context, tag)
        inserter.insert tag.to_snippet_tag # @snip -> @snippet
        inserter.insert src
        visit tag
      end

      # Insert depended snippet
      def insert_depended_snippets!(inserter, snippet, context, tag)
        dep_tags = dep_searcher.find(snippet.lines, context, tag)
        dep_tags = sort_dep_tags_by_dep(dep_tags)

        dep_tags.each do |tag_info|
          sub_t = tag_info[:tag]
          sub_c = tag_info[:context]

          next if is_visited(sub_t)

          sub_snippet = repo_manager.get_snippet(sub_c, sub_t)
          insert_by_tag_and_context! inserter, sub_snippet, sub_c, sub_t
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
        dep_tags_hash = {}
        dep_tags.each do |tag_info|
          tag = tag_info[:tag].to_path
          dep_ind = dep_tags_index[tag]
          dep_tags_hash[dep_ind] = dep_searcher.dep_to[tag].to_a.map {|tag| dep_tags_index[tag] }
        end

        dep_tags_hash.tsort.map {|k| dep_tags[k]}
      end

    end
  end
end
