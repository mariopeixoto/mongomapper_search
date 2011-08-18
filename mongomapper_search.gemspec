# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'mongomapper_search'

Gem::Specification.new do |s|
  s.name        = "mongomapper_search"
  s.version     = "0.0.1"
  s.authors     = ["Mário Peixoto"]
  s.email       = ["mario.peixoto@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "mongomapper_search"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("mongo_mapper", [">= 0.9.1"])
  s.add_dependency("bson_ext", [">= 1.2.0"])
  s.add_dependency("fast-stemmer", ["~> 1.0.0"])
  
  s.add_development_dependency("rake", ["~> 0.9.2"])
  s.add_development_dependency("rspec", ["~> 2.4"])
end
