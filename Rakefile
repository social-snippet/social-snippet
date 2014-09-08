require "bundler/gem_tasks"

task :default => [:spec]

require "rspec/core/rake_task"

# rake spec
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = [
    "--format documentation",
    "--color",
  ]
end

# rake test
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = [
    "--pattern '../test/*_test.rb'",
    "--color",
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

