# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_label/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_label"
  s.version     = Coroutine::ActsAsLabel::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Coroutine", "John Dugan"]
  s.email       = ["gems@coroutine.com"]
  s.homepage    = "http://github.com/coroutine/acts_as_label"
  s.summary     = %q{This acts_as extension simplifies the process of assigning mutable user-friendly labels to immutable system labels.}
  s.description = %q{This acts_as extension implements a system label and a friendly label on a class and centralizes the logic for performing validations and accessing items by system label.}

  s.add_dependency "rails", ">= 3.0.0"
  
  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "sqlite3", ">= 1.3.6"
  
  s.rubyforge_project = "acts_as_label"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
