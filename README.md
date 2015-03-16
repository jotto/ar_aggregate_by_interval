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
# be explicit and pass a hash
# [:group_by_column, :from, :to, :aggregate_column]

# or just pass arguments
# count: arg_hash can be arguments: (group_by_col, from, to)
# sum and avg: arg_hash can be arguments: (group_by_col, aggregate_col, from, to)
Blog.{count,sum,avg}_{daily,weekly,monthly}(arg_hash).{values,values_and_dates}
```

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
