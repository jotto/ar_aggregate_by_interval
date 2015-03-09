require 'active_record'
require 'ar_aggregate_by_interval/query_runner'
require 'ar_aggregate_by_interval/utils'

# POSTGRES AND MYSQL COMPATIBLE
# ActiveRecordModel.[sum|count]_[daily|weekly|monthly]
# examples:

module ArAggregateByInterval

  def method_missing(method_name, *args)
    supported_methods_rgx = /\A(count|sum|avg)_(daily|weekly|monthly)\z/

    aggregate_function, interval = method_name.to_s.scan(supported_methods_rgx).flatten

    return super unless aggregate_function && interval

    hash_args = if args.size == 1 && args.first.is_a?(Hash)
      args.first
    elsif args.size > 1 && !args.any?{ |a| a.is_a?(Hash) }
      Utils.args_to_hash(aggregate_function, interval, *args)
    else
      nil
    end

    return super unless hash_args

    # convert strings to symbols
    [:group_by_column, :aggregate_column].each do |col|
      hash_args[col] = hash_args[col].intern if hash_args[col]
    end

    # build query object
    query_runner = QueryRunner.new(self, {
      aggregate_function: aggregate_function,
      interval: interval
    }.merge(hash_args))

    # actually run SQL and return a hash of dates => vals
    date_values_hash = query_runner.run_query

    # takes hash and fills in missing dates
    # this QueryResult object has 2 attributes: values_and_dates, values
    QueryResult.new({
      date_values_hash: date_values_hash,
      from: query_runner.from,
      to: query_runner.to,
      interval: query_runner.interval
    })

  end

end

# for queries on the class
ActiveRecord::Base.send :extend, ArAggregateByInterval
# for scoped queries
ActiveRecord::Relation.send :include, ArAggregateByInterval
