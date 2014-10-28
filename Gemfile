source 'https://rubygems.org'

# Specify your gem's dependencies in social-snippet.gemspec
gemspec

# Misc
gem "bundler", "~> 1.6", :require => false
gem "rake", "~> 10.0", :require => false
gem "yard", :require => false
gem "pry", :require => false
gem "guard", :require => false
gem "guard-shell", :require => false

# Test
gem "rspec", :require => false
gem "fakefs", :require => false
gem "webmock", :require => false

# Debug
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.0.0')
  gem "byebug", :require => false
  gem "pry-byebug", :require => false
else
  gem "debugger", :require => false
end
