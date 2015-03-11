module SocialSnippet

  class Resolvers::BaseResolver

    attr_reader :core
    attr_reader :visited

    # Constructor
    #
    # @param new_core [::SocialSnippet::Core]
    def initialize(new_core)
      @core = new_core
      @visited = Set.new
    end

    # Call block each snip tags
    #
    # @param snippet [Snippet]
    # @param context [Context] The context of current code
    # @param base_tag [Tag]
    def each_child_snippet(snippet, context, base_tag)
      raise "must be passed snippet" unless snippet.is_a?(Snippet)

      snippet.snip_tags.each do |tag_info|
        t = tag_info[:tag].set_by_tag(base_tag)
        new_context = context.clone

        if new_context.root_text?
          new_context.set_path ""
          move_context_by_tag! new_context, t
        else
          move_context_by_tag! new_context, t
          overwrite_tag_in_same_repository! new_context, t
          update_tag_path_by_context! new_context, t
          resolve_tag_repo_ref! t
        end

        resolve_tag_repo_ref! t
        child_snippet = core.repo_manager.get_snippet(new_context, t)
        t.set_path new_context.path

        if block_given?
          yield t, tag_info[:line_no], child_snippet, new_context
        end
      end
    end

    private

    def resolve_tag_repo_ref!(t)
      if t.has_repo?
        package = core.repo_manager.find_package_by_tag(t)
        t.set_ref package.latest_version(t.ref)
      end
    end

    def move_context_by_tag!(context, tag)
      if tag.has_repo?
        if tag.has_ref?
          context.move tag.path, tag.repo, tag.ref
        else
          context.move tag.path, tag.repo
        end
      else
        context.move tag.path
      end
    end

    # Overwrite tag
    def overwrite_tag_in_same_repository!(context, tag)
      if context.is_in_repository? && tag.has_repo? === false
        tag.set_repo context.repo
        tag.set_ref context.ref
      end
    end

    # Update tag path by context
    def update_tag_path_by_context!(context, tag)
      if tag.has_repo?
        tag.set_path context.path
      end
    end

    # Resolve tag's ref
    def resolve_tag_repo_ref!(tag)
      return unless tag.has_repo?
      repo = core.repo_manager.find_repository(tag.repo)
      # set latest version
      if tag.has_ref? === false
        if repo.has_versions?
          tag.set_ref repo.latest_version
        else
          tag.set_ref repo.current_ref
        end
      end
    end

    def visit(tag)
      visited.add tag.to_path
    end

    def is_visited(tag)
      visited.include? tag.to_path
    end

    def is_self(tag, context)
      tag.repo === context.repo && tag.path === context.path
    end

  end

end
