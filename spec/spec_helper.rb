require "bundler/setup"
require_relative "helpers/codeclimate_helper"
require_relative "helpers/webmock_helper"

require "social_snippet"
require "json"
require "cgi"
require "stringio"

require_relative "helpers/fakefs_helper"
require_relative "helpers/social_snippet_helper"
require "social_snippet/rspec/test_document"

RSpec.configure do |config|
  config.before(:example, :without_fakefs => true) do
    disable_fakefs
    make_fake_home
  end
end
