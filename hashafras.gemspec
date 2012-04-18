# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hashafras/version"

Gem::Specification.new do |s|
  s.name        = "hashafras"
  s.version     = Hashafras::VERSION
  s.authors     = ["Tim Ariyeh"]
  s.email       = ["tim.ariyeh@gmail.com"]
  s.homepage    = "https://github.com/timariyeh/hashafras"
  s.summary     = %q{Stupid-simple consistent hashing for Ruby}
  s.description = %q{}

  s.rubyforge_project = "hashafras"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
