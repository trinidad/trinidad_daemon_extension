begin
  require 'bundler/setup'
rescue LoadError => e
  require('rubygems') && retry
  raise e
end

task :default => :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--color', "--format documentation"]
end

require 'bundler/gem_tasks'

desc "Clear out all built (pkg/* and *.gem) artifacts"
task :clear do
  rm Dir["*.gem"]
  rm_r Dir["pkg/*"] if File.exist?("pkg")
end
task :clean => :clear
