module SocialSnippet::Repository

  class RepositoryFactory

    @@drivers = [Drivers::GitDriver]

    attr_reader :core

    def initialize(new_core)
      @core = new_core
    end

    def reset_drivers
      @@drivers = []
    end

    def add_driver(driver_class)
      @@drivers.push driver_class
    end

    # @param url [String] The URL of repository
    # @reutrn [::SocialSnippet::Repository::Drivers::DriverBase]
    def clone(url, ref = nil)
      driver = resolve_driver(url)
      driver.fetch
      driver.cache(ref)
      driver
    end

    def resolve_driver(url)
      driver_class = @@drivers.select do |driver_class|
        driver_class.target? url
      end.first
      if driver_class.nil?
        raise "ERROR: driver not found"
      else
        driver_class.new core, url
      end
    end

  end # class << self

end # RepositoryFactory
