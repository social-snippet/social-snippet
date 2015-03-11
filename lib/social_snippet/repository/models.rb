module SocialSnippet::Repository::Models

  def self.const_missing(name)
    if name === :Package
      require_relative "models/package"
      ::SocialSnippet::Repository::Models::Package
    elsif name === :Repository
      require_relative "models/repository"
      ::SocialSnippet::Repository::Models::Repository
    else
      super
    end
  end

end
