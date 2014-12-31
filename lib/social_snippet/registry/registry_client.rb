module SocialSnippet::Registry

  class RegistryClient

    attr_reader :social_snippet
    attr_reader :repositories

    def initialize(new_social_snippet)
      @social_snippet = new_social_snippet
      @repositories = RegistryResources::Repositories.new(social_snippet)
    end

  end

end
