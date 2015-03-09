require 'active_support'
require 'active_support/core_ext'
require 'classy_hash'
require 'ar_aggregate_by_interval/utils'
require 'ar_aggregate_by_interval/query_result'

module ArAggregateByInterval

  class QueryRunner

    VALID_HASH_ARGS = {
      aggregate_function: [String], # sum, count
      interval: [String], # daily, weekly, monthly
      group_by_column: [Symbol], # i.e.: :created_at

      from: [Date, DateTime, Time, ActiveSupport::TimeWithZone],
      to: [:optional, Date, DateTime, Time, ActiveSupport::TimeWithZone],

      aggregate_column: [:optional, Symbol, NilClass] # required when using sum (as opposed to count)
    }

    attr_reader :values, :values_and_dates, :from, :to, :interval

    def initialize(ar_model, hash_args)

      validate_args!(hash_args)

      @ar_model = ar_model

      @from = normalize_from(hash_args[:from], hash_args[:interval])
      @to = normalize_to(hash_args[:to] || Time.zone.try(:now) || Time.now, hash_args[:interval])

      @db_vendor_select =
        Utils.select_for_grouping_column(hash_args[:group_by_column])[hash_args[:interval]]

      @aggregate_function = hash_args[:aggregate_function]
      @aggregate_column = hash_args[:aggregate_column]
      @group_by_column = hash_args[:group_by_column]

      @interval = hash_args[:interval]
    end

    def run_query
      # actually run query
      array_of_pairs = ActiveRecord::Base.connection.select_rows(to_sql)

      # workaround ActiveRecord's automatic casting to Date objects
      # (ideally we could return raw values straight from ActiveRecord to avoid this expensive N)
      array_of_pairs.collect! do |date_val_pair|
        date_val_pair.collect(&:to_s)
      end

      # convert the array of key/values to a hash
      Hash[array_of_pairs]
    end

    private

    def to_sql
      # first col is date, second col is actual value
      query = @ar_model.
        select("#{@db_vendor_select} as datechunk__").
        select("#{@aggregate_function}(#{@aggregate_column || '*'}) as totalchunked__").
        where(["#{@group_by_column} >= ? and #{@group_by_column} <= ?", @from, @to]).
        group('datechunk__')

      # workaround Postgres adapter's insistence of adding an order clause
      query = query.order(nil)

      # an string of the query to run
      query.to_sql
    end

    def validate_args!(hash_args)
      ClassyHash.validate(hash_args, VALID_HASH_ARGS)
      if hash_args[:aggregate_function] != 'count' && hash_args[:aggregate_column].blank?
        raise RuntimeError.new('must pass the :aggregate_column arg')
      end
    end

    # adjust "to" to end of day, week or month (if less than now)
    def normalize_to(to, interval)
      adjusted_to = to.send(Utils.interval_inflector(interval, 'end'))
      if adjusted_to < (Time.zone.try(:now) || Time.now)
        adjusted_to
      else
        to
      end
    end

    # adjust "from" to beginning of day, week or month
    def normalize_from(from, interval)
      from.send(Utils.interval_inflector(interval, 'beginning'))
    end

  end
end
