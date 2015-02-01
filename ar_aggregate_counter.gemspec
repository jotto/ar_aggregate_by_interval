# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ar_aggregate_by_interval/version'

Gem::Specification.new do |s|
  s.name        = 'ar_aggregate_by_interval'
  s.version     = ArAggregateByInterval::VERSION
  s.authors     = ['Jonathan Otto']
  s.email       = ['jonathan.otto@gmail.com']
  s.homepage    = 'https://github.com/jotto/ar_aggregate_by_interval'
  s.summary     = 'add [sum|count]_[daily|weekly|monthly] to your AR models for MySQL AND Postgres'
  s.description = 'add [sum|count]_[daily|weekly|monthly] to your AR models for MySQL AND Postgres'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', '~> 1.5'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'database_cleaner', '~> 1.4'
  s.add_development_dependency 'guard-rspec', '~> 4.5'
  s.add_development_dependency 'sqlite3'
  s.add_dependency 'activesupport', '~> 4.0'
  s.add_dependency 'activerecord', '~> 4.0'
  s.add_dependency 'classy_hash', '~> 0.1'
  s.add_dependency 'date_iterator'

end
