require 'ar_aggregate_by_interval/query_runner'
require 'ar_aggregate_by_interval/utils'

# POSTGRES AND MYSQL COMPATIBLE
# ActiveRecordModel.[sum|count]_[daily|weekly|monthly]
# examples:

module ArAggregateByInterval

  def method_missing(method_name, *args)
    supported_methods_rgx = /\A(sum|count)_(daily|weekly|monthly)\z/

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

    QueryRunner.new(self, {
      aggregate_function: aggregate_function,
      interval: interval
    }.merge(hash_args))

  end

end

# for queries on the class
ActiveRecord::Base.send :extend, ArAggregateByInterval
# for scoped queries
ActiveRecord::Relation.send :include, ArAggregateByInterval