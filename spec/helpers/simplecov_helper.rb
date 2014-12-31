if ENV["TRAVIS"] == "true"
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
    add_filter "/spec/"
    add_filter "/vendor/"
  end
end

