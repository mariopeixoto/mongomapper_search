require 'rubygems'
require 'rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ["-c", "-f progress"]
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec