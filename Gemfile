source 'https://rubygems.org'

gem "bundler"
gem "rake"
gem "version_sorter"
gem "rugged"
gem "rest-client"

group :development do
  gem "yard", :require => false
  gem "pry", :require => false
  gem "guard", :require => false
  gem "guard-shell", :require => false
end

group :test do
  gem "rspec", :require => false
  gem "fakefs", :require => false
  gem "webmock", :require => false
  gem "simplecov", :require => false
  gem "codeclimate-test-reporter", :require => false
end

# should be disabled on travis-ci
group :debug do
  gem "pry-byebug", :require => false
end
