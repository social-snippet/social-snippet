module SocialSnippet

  class Resolvers::InsertResolver < Resolvers::BaseResolver

    attr_reader :deps_resolver
    attr_reader :options

    # Constructor
    #
    # @param core [::SocialSnippet::Core]
    def initialize(core, new_options = {})
      @options = new_options
      @deps_resolver = Resolvers::DepResolver.new(core)
      super(core)
      init_options
    end

    def init_options
      parse_snippet_css
      options[:margin_bottom] = options.fetch(:margin_bottom, 0)
      options[:margin_top] = options.fetch(:margin_top, 0)
    end

    def convert_to_option_key(prop)
      case prop
      when "margin-bottom"
        :margin_bottom
      when "margin-top"
        :margin_top
      else
        prop.to_sym
      end
    end

    def parse_snippet_css
      return unless core.storage.file?("snippet.css")
      parser = ::CssParser::Parser.new
      parser.add_block! core.storage.read("snippet.css")
      style = parser.find_by_selector("snippet").first
      rules = ::CssParser::RuleSet.new(nil, style)
      rules.each_declaration do |prop, val, imp|
        key = convert_to_option_key(prop)
        options[key] = options.fetch(key, val.to_i)
      end
    end

    # Insert snippets to given text
    #
    # @param text [String] The text of source code
    def insert(text)
      raise "must be passed string" unless text.is_a?(String)

      snippet = Snippet.new_text(core, text)
      snippet.snippet_tags.each do |tag_info|
        visit tag_info[:tag]
      end

      context = Context.new(nil)
      insert_func(snippet, context).join($/)
    end

    private

    def insert_func(snippet, context_from, base_tag = nil)
      raise "must be passed snippet" unless snippet.is_a?(Snippet)

      inserter = Inserter.new(snippet.lines)
      context = context_from.clone

      # replace each @snip tags
      each_child_snippet(snippet, context, base_tag) do |tag, line_no, child_snippet, new_context|
        inserter.set_index line_no
        inserter.ignore

        visit(tag) if is_self(tag, context)
        next if is_visited(tag)

        insert_depended_snippets! inserter, child_snippet, new_context, tag
        insert_by_tag_and_context! inserter, child_snippet, new_context, tag
      end

      inserter.set_index_last
      return inserter.dest
    end

    # Insert snippet by tag and context
    def insert_by_tag_and_context!(inserter, snippet, context, tag)
      raise "must be passed snippet" unless snippet.is_a?(Snippet)

      src = insert_func(snippet, context, tag)

      options[:margin_top].times { inserter.insert "" }
      # @snip -> @snippet
      inserter.insert tag.to_snippet_tag unless snippet.no_tag?
      # insert snippet text
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
        resolve_tag_repo_ref! sub_t

        visit(tag) if is_self(sub_t, sub_c)
        next if is_visited(sub_t)

        next_snippet = core.repo_manager.get_snippet(sub_c, sub_t)
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
        dep_tags_hash[dep_ind] = deps_resolver.dep_to[tag].to_a.map {|tag| dep_tags_index[tag] }.reject(&:nil?)
      end

      dep_tags_hash.tsort.map {|k| dep_tags[k] }
    end

  end # BaseResolver

end # SocialSnippet
