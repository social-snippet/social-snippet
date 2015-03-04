module FakeFSHelpers

  require "fakefs/safe"

  def disable_fakefs
    FakeFS.deactivate!
    FakeFS::FileSystem.clear
  end

  def enable_fakefs
    FakeFS.activate!
  end

end

module SocialSnippet
  ::RSpec.configure do |config|
    config.include FakeFSHelpers
    config.before { enable_fakefs }
    config.after { disable_fakefs }
  end
end

$WITHOUT_FAKEFS = (ENV["RSPEC_WITHOUT_FAKEFS"] === "true")
