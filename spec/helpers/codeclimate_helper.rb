if ENV["TRAVIS"] === "true" && ENV["ENABLE_CODECLIMATE"] === "true"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
