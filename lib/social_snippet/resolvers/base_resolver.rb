module SocialSnippet

  class Resolvers::BaseResolver

    attr_reader :social_snippet
    attr_reader :visited

    # Constructor
    #
    # @param new_social_snippet [::SocialSnippet::Core]
    def initialize(new_social_snippet)
      @social_snippet = new_social_snippet
      @visited = Set.new
    end

    # Call block each snip tags
    #
    # @param src [Array<String>] The text of source code
    # @param context [SocialSnippet::Context] The context of current code
    # @param base_tag [SocialSnippet::Tag]
    def each_snip_tags(src, context, base_tag)
      TagParser.find_snip_tags(src).each do |tag_info|
        t = tag_info[:tag].set_by_tag(base_tag)
        new_context = context.clone

        move_context_by_tag! new_context, t
        overwrite_tag_in_same_repository! context, t
        update_tag_path_by_context! new_context, t
        resolve_tag_repo_ref! t

        snippet = social_snippet.repo_manager.get_snippet(context, t)

        if block_given?
          yield(
            tag_info[:tag],
            tag_info[:line_no],
            snippet,
            new_context
          )
        end
      end
    end

    private

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
      repo = social_snippet.repo_manager.find_repository_by_tag(tag)

      # not found
      return if repo.nil?

      if tag.has_ref? === false || tag.ref != repo.latest_version(tag.ref)
        if repo.has_versions?
          tag.set_ref repo.latest_version(tag.ref)
        else
          tag.set_ref repo.short_commit_id
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
