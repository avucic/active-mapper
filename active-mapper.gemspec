$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active-mapper/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active-mapper"
  s.version     = ActiveMapper::VERSION
  s.authors     = ["Aleksandar Vucic"]
  s.email       = ["aleksandar.vucic@hrsrbija.rs"]
  s.homepage    = "http://hrsrbija.rs"
  s.summary     = "ORM."
  s.description = "ORM."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency("multi_json")
  s.add_dependency("activemodel", '~> 3.2')
  s.add_development_dependency("rspec",'~> 2.1')
end
