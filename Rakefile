require "rake"
require "rake/testtask"
require "rake/rdoctask"
require "jeweler"


desc "Default: run tests."
task :default => [:test]


desc "Test the gem."
Rake::TestTask.new(:test) do |t|
  t.libs    << ["lib", "test"]
  t.pattern  = "test/**/*_test.rb"
  t.verbose  = true
end


desc "Generate documentation for the gem."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title    = "acts_as_label"
  rdoc.options << "--line-numbers --inline-source"
  rdoc.rdoc_files.include("README")
  rdoc.rdoc_files.include("lib/**/*.rb")
end


begin
  Jeweler::Tasks.new do |gemspec|
    gemspec.authors           = ["Coroutine", "John Dugan"]
    gemspec.description       = "This acts_as extension implements a system label and a friendly label on a class and centralizes the logic for performing validations and accessing items by system label."
    gemspec.email             = "jdugan@coroutine.com"
    gemspec.homepage          = "http://github.com/coroutine/acts_as_label"
    gemspec.name              = "acts_as_label"
    gemspec.summary           = "Gem version of acts_as_label Rails plugin."
    
    gemspec.add_dependency("activerecord", ">=2.3.4")
    gemspec.add_development_dependency("activesupport", ">=2.3.4")
    gemspec.files.include("lib/**/*.rb")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end