module SocialSnippet::Registry

  class RegistryClient

    attr_reader :core
    attr_reader :repositories

    def initialize(new_core)
      @core = new_core
      @repositories = RegistryResources::Repositories.new(core)
    end

  end

end
