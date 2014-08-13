require "bundler/gem_tasks"

task :default => [:spec]

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new :spec


require "yard"
require "yard/rake/yardoc_task"

# rake yard
YARD::Rake::YardocTask.new do |t|
  t.files = [
    "lib/{,**}/*.rb"
  ]
end

