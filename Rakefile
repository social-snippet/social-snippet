require "bundler/gem_tasks"

task :default => [:spec]

require "rspec/core/rake_task"

# rake spec
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag ~use_raw_filesystem",
  ]
end

# rake spec_use_fs
RSpec::Core::RakeTask.new(:spec_use_fs) do |t|
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag use_raw_filesystem",
  ]
end

# rake test
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = [
    "--pattern '../test/*_test.rb'",
    "--color",
    "--tag ~use_raw_filesystem",
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

