# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).
This file adheres to [Keep a changelog](http://keepachangelog.com/).

## [1.2.0] - 2015-04-05
### Added
- normalize_dates option

## [1.1.7] - 2015-03-15 (maintenance)
### Added
- Tests for from and to parameters

## [1.1.6] - 2015-03-15 (maintenance)
### Added
- Tests run on MySQL, Postgres and SQLite

### Changed
- Remove memoization from Utils

## [1.1.5] - 2015-03-08 (maintenance)
### Changed
- Raise ArgumentError instead of NoMethodError or RuntimeError on bad args

## [1.1.4] - 2015-03-08 (maintenance)
### Changed
- Moved functionality from constructors to methods
- Build hash from `select_rows` instead of AR objects (performance, simplicity)
- Driver of functionality now in method_missing (decoupling)

## [1.1.3] - 2015-03-02
### Fixed
- Fix Postgres queries due to AR injecting order clause
- Fix `daily` methods due to AR interpretting dates as Ruby date objects
- Allow running from IRB

## [1.1.2] - 2015-03-01
### Fixed
- Allow symbols to fix incorrect enforcement of strings for SQL columnn names
- Accept anything responding to `to_a` to fix inability to pass ActiveRecord associations (arrays) (as opposed to relations) to `QueryResult`

## [1.1.0] - 2015-03-01 (initial Gem release)
### Added
- Averages (`avg_daily`, `avg_weekly`, `avg_monthly`)

### Fixed
- Adjust the core `method_missing` to be included in `ActiveRecord::Relation` in addition to `ActiveRecord::Base` to fix running these functions on scoped ActiveRecord queries
- Correct inflector so *_daily methods stop raising exception

### Changed
- Gemified project
