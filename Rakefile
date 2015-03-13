require "bundler/setup"
require "bundler/gem_tasks"

task :default => [:spec]


#
# Testing
#

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec_all) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "false"
  ENV["ENABLE_CODECLIMATE"] = "false"
  t.pattern = [
    'spec/**/*_spec.rb',
    'test/**/*_test.rb',
  ]
  t.rspec_opts = [
    "--color",
    "--tag ~without_fakefs",
  ]
end

RSpec::Core::RakeTask.new(:spec_all_without_fakefs) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "true"
  ENV["ENABLE_CODECLIMATE"] = "true"
  t.pattern = [
    'spec/**/*_spec.rb',
    'test/**/*_test.rb',
  ]
  t.rspec_opts = [
    "--color",
  ]
end

RSpec::Core::RakeTask.new(:spec) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "false"
  ENV["ENABLE_CODECLIMATE"] = "false"
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag ~without_fakefs",
  ]
end

RSpec::Core::RakeTask.new(:spec_current) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "false"
  ENV["ENABLE_CODECLIMATE"] = "false"
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag current",
  ]
end

RSpec::Core::RakeTask.new(:spec_without_fakefs) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "true"
  ENV["ENABLE_CODECLIMATE"] = "false"
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag without_fakefs",
  ]
end

RSpec::Core::RakeTask.new(:test) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "false"
  ENV["ENABLE_CODECLIMATE"] = "false"
  t.rspec_opts = [
    "--pattern '../test/*_test.rb'",
    "--color",
    "--tag ~without_fakefs",
  ]
end

RSpec::Core::RakeTask.new(:test_current) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "false"
  ENV["ENABLE_CODECLIMATE"] = "false"
  t.rspec_opts = [
    "--pattern '../test/*_test.rb'",
    "--color",
    "--tag ~without_fakefs",
    "--tag current",
  ]
end

RSpec::Core::RakeTask.new(:test_without_fakefs) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "true"
  ENV["ENABLE_CODECLIMATE"] = "false"
  t.rspec_opts = [
    "--pattern '../test/*_test.rb'",
    "--color",
    "--tag without_fakefs",
  ]
end


#
# Documentation
#

require "yard"
require "yard/rake/yardoc_task"

# rake yard
YARD::Rake::YardocTask.new do |t|
  t.files = [
    "lib/{,**}/*.rb"
  ]
end

