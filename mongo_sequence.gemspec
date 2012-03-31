# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "mongo_sequence"
  s.version     = '0.9.0'
  s.authors     = ["Brian Hempel"]
  s.email       = ["plasticchicken@gmail.com"]
  s.homepage    = "github.com/brianhempel/mongo_sequence"
  s.summary     = %q{Light-weight sequences for MongoDB, useful for auto-incrementing or counting.  Works with any ODM.}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "mongo", ">1.1"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "mongo_mapper"
  s.add_development_dependency "mongoid"
end
