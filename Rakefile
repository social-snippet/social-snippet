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


require "yard"
require "yard/rake/yardoc_task"

# rake yard
YARD::Rake::YardocTask.new do |t|
  t.files = [
    "lib/{,**}/*.rb"
  ]
end

