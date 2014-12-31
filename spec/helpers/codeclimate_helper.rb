if ENV["TRAVIS"] == "true"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
