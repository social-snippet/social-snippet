module SocialSnippet::Api::InsertSnippetApi

  # Insert snippets to given text.
  # $ ssnip
  #
  # @param src [String] The text of source code
  #
  def insert_snippet(src, options = {})
    raise "must be passed string" unless src.is_a?(String)
    resolver = ::SocialSnippet::Resolvers::InsertResolver.new(social_snippet, options)
    res = resolver.insert(src)
    output res
    res
  end

end
