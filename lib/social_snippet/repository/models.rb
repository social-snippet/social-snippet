module SocialSnippet::Repository::Models

  def self.const_missing(name)
    if name == :Package
      require_relative "models/package"
      ::SocialSnippet::Repository::Models::Package
    else
      super
    end
  end

end
