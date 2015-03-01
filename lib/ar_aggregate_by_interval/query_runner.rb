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

    attr_reader :values, :values_and_dates

    def initialize(ar_model, hash_args)

      validate_args!(hash_args)

      from = normalize_from(hash_args[:from], hash_args[:interval])
      to = normalize_to(hash_args[:to] || Time.zone.try(:now) || Time.now, hash_args[:interval])

      db_vendor_select_for_date_function =
        Utils.select_for_grouping_column(hash_args[:group_by_column])[hash_args[:interval]]

      ar_result = ar_model.
        select("#{hash_args[:aggregate_function]}(#{hash_args[:aggregate_column] || '*'}) as totalchunked__").
        select("#{db_vendor_select_for_date_function} as datechunk__").
        group('datechunk__').
        where(["#{hash_args[:group_by_column]} >= ? and #{hash_args[:group_by_column]} <= ?", from, to])

      # fill the gaps of the sql results
      agg_int = QueryResult.new({
        ar_result: ar_result,
        ar_result_select_col_mapping: {'datechunk__' => 'totalchunked__'},
        from: from,
        to: to,
        interval: hash_args[:interval]
      })

      @values_and_dates = agg_int.values_and_dates
      @values = @values_and_dates.collect { |hash| hash[:value] }

    end

    private

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
