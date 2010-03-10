require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'jeweler'


desc 'Default: run tests.'
task :default => [:test]


desc 'Test the plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end


desc 'Generate documentation for the plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'acts_as_label'
  rdoc.options << '--line-numbers --inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


begin
  Jeweler::Tasks.new do |gemspec|
    gemspec.name              = "acts_as_label"
    gemspec.summary           = "Gem version of acts_as_label Rails plugin."
    gemspec.description       = "This acts_as extension implements a system label and a friendly label on a class and centralizes the logic for performing validations and accessing items by system label."
    gemspec.email             = "jdugan@coroutine.com"
    gemspec.homepage          = "http://github.com/coroutine/acts_as_label"
    gemspec.authors           = ["Coroutine", "John Dugan"]
    gemspec.add_dependency "activesupport"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

