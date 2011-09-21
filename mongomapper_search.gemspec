# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "mongomapper_search"
  s.version     = "0.1.1"
  s.authors     = ["Mário Peixoto"]
  s.email       = ["mario.peixoto@gmail.com"]
  s.homepage    = "http://github.com/mariopeixoto/mongomapper_search"
  s.summary     = "Search implementation for MongoMapper ODM"
  s.description = "Simple full text search for MongoMapper ODM"

  s.required_rubygems_version = ">= 1.3.6"

  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.md Rakefile)
  s.test_files = Dir.glob("spec/**/*")
  s.require_paths = ["lib"]
  
  s.add_dependency("mongo_mapper", [">= 0.9.1"])
  s.add_dependency("bson_ext", [">= 1.2.0"])
  s.add_dependency("fast-stemmer", ["~> 1.0.0"])
  
  s.add_development_dependency("database_cleaner", ["~> 0.6.4"])
  s.add_development_dependency("rake", ["~> 0.9.2"])
  s.add_development_dependency("rspec", ["~> 2.4"])
end
