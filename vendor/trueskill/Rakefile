require 'rubygems'
require 'rake'
require 'bundler'

Bundler.setup
Bundler.require

require "rspec/core/rake_task"

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
RSpec::Core::RakeTask.new(:spec) do |t|
end

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/**/*.rb', 'HISTORY.md']
  t.options = ['--no-private', '--title', 'trueskill Documentation', '--readme', 'README.md']
end
