require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'


desc 'Default: run unit tests.'
task :default => [:clean_db, :test]

desc 'Remove the stale db file'
task :clean_db do
  `rm -f #{File.dirname(__FILE__)}/test/acts_as_label.sqlite.db`
end

desc 'Test the acts_as_label plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the acts_as_label plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Acts As Label'
  rdoc.options << '--line-numbers --inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
