require "social_snippet"

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.0.0')
  require "byebug"
else
  require "debugger"
end
