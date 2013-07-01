$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ar_aggregate_counter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ar_aggregate_counter"
  s.version     = ArAggregateCounter::VERSION
  s.authors     = ["Jonathan Otto"]
  s.email       = ["jonathan.otto@gmail.com"]
  s.homepage    = ""
  s.summary     = "adds [sum|count]_[daily|weekly|monthly] to your AR models for MySQL AND Postgres"
  s.description = "adds [sum|count]_[daily|weekly|monthly] to your AR models for MySQL AND Postgres"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "date_iterator"
  s.add_dependency "rails", "~> 4.0.0"

end
