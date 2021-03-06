module SocialSnippet::Repository::DriverFactory

  @@drivers = []

  class << self

    def drivers
      @@drivers
    end

    def reset_drivers
      @@drivers = []
    end

    def add_driver(driver_class)
      drivers.push driver_class
    end

    # @param url [String] The URL of repository
    # @reutrn [::SocialSnippet::Repository::Drivers::DriverBase]
    def clone(url)
      driver = resolve_driver(url)
      driver.fetch
      driver
    end

    def resolve_driver(url)
      driver_class = drivers.select do |driver_class|
        driver_class.target? url
      end.first
      if driver_class.nil?
        raise "ERROR: driver not found"
      else
        driver_class.new url
      end
    end

  end # class << self

end # DriverFactory

