# ArAggregateByInterval
---
Build arrays of counts, sums and averages from Ruby on Rails ActiveRecord models grouped by days, weeks or months. e.g.:
```ruby
# default 'group by' is 'created_at'
Blog.count_weekly(1.month.ago).values
=> [4, 2, 2, 0]
```

## Why?
1. to simplify "group by" SQL queries when weeks or months are involved
2. to fill in 0's for days/weeks/months where database has no data

## Usage
```ruby
ActiveRecordModel.{sum,count,avg}_{daily,weekly,monthly}(arg_hash).{values,values_and_dates}
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