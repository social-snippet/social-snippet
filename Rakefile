require "bundler/setup"
require "bundler/gem_tasks"

task :default => [:spec]

require "rspec/core/rake_task"

# rake spec
RSpec::Core::RakeTask.new(:spec) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "false"
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag ~without_fakefs",
  ]
end

# rake spec_current
RSpec::Core::RakeTask.new(:spec_current) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "false"
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag current",
  ]
end

# rake spec_without_fs
RSpec::Core::RakeTask.new(:spec_without_fakefs) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "true"
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag without_fakefs",
  ]
end

# rake test
RSpec::Core::RakeTask.new(:test) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "false"
  t.rspec_opts = [
    "--pattern '../test/*_test.rb'",
    "--color",
    "--tag ~without_fakefs",
  ]
end

# rake test_without_fakefs
RSpec::Core::RakeTask.new(:test_without_fakefs) do |t|
  ENV["RSPEC_WITHOUT_FAKEFS"] = "true"
  t.rspec_opts = [
    "--pattern '../test/*_test.rb'",
    "--color",
    "--tag without_fakefs",
  ]
end

require "yard"
require "yard/rake/yardoc_task"

# rake yard
YARD::Rake::YardocTask.new do |t|
  t.files = [
    "lib/{,**}/*.rb"
  ]
end

