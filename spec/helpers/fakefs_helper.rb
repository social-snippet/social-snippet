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

