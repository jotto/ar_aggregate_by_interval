# ArAggregateByInterval
## ActiveRecord time series
---

[![Circle CI](https://circleci.com/gh/jotto/ar_aggregate_by_interval.svg?style=svg)](https://circleci.com/gh/jotto/ar_aggregate_by_interval)

For MySQL or Postgres.

Build arrays of counts, sums and averages from Ruby on Rails ActiveRecord models grouped by days, weeks or months. e.g.:
```ruby
# (group_by_col, from, to = Time.now)
Blog.count_weekly(:created_at, 1.month.ago).values
=> [4, 2, 2, 0]

# (group_by_col, aggregate_col, from, to = Time.now)
Blog.sum_weekly(:created_at, :pageviews, 1.month.ago).values
=> [400, 350, 375, 250]

# (group_by_col, aggregate_col, from, to = Time.now)
Blog.avg_weekly(:created_at, :pageviews, 1.month.ago).values
=> [25, 20, 40, 10]
```

## Why?
1. to simplify "group by" SQL queries when weeks or months are involved
2. to fill in 0's for days/weeks/months where database has no data

## Usage
```ruby
Blog.{count,sum,avg}_{daily,weekly,monthly}(hash_or_arg_list).{values,values_and_dates}`
```

### 1. "method_missing" methods on ActiveRecord
* `{count,sum,avg}_{daily,weekly,monthly}`

### 2. pass hash or argument list

* pass a Hash
  * `{:group_by_column, :from, :to, :aggregate_column, :normalize_dates}`
* or pass arguments
  * when using count: `[group_by_col, from, to, options_hash]`
  * when using sum or avg: `[group_by_col, aggregate_col, from, to, options_hash]`

### 3. methods you can call: `#values` or `#values_and_dates`

```ruby
#values //(returns an array of numerics)
=> [4, 2, 15, 0, 10]
```
```ruby
#values_and_dates //(returns an array of hashes)
=> [{date: DateObject, value: 0}, {date: DateObject, value: 5}]
```
## Examples
#### Total blog posts created weekly
```ruby
Blog.count_weekly({
  group_by_column: :created_at,
  from: 6.months.ago,
  to: Time.zone.now
}).values
```

#### Total calories burned per week
```ruby
Exercise.sum_weekly({
  group_by_column: :created_at,
  aggregate_column: :calories,
  from: 6.months.ago,
  to: Time.zone.now
}).values
```

#### Weekly revenue since beginning of year (with dates)
```ruby
Billing.sum_weekly({
  group_by_column: :transacted_at,
  aggregate_column: :cents, # necessary when using sum as opposed to count
  from: Time.zone.now.beginning_of_year,
  to: Time.zone.now
}).values_and_dates
```

## Options
* `normalize_dates` defaults to `True` which means the `from` argument is converted to beginning_of_{day,week,month} and the `to` argument is converted to end_of_{day,week,month}
