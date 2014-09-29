require "social_snippet"
require "json"

require "fakefs/safe"

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.0.0')
  require "byebug"
else
  require "debugger"
end
