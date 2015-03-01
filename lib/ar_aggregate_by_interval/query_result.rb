require 'active_support'
require 'active_support/core_ext'
require 'classy_hash'
require 'date_iterator'
require 'ar_aggregate_by_interval/utils'

module ArAggregateByInterval

  class QueryResult

    VALID_HASH_ARGS = {
      ar_result: -> (v) { v.respond_to?(:to_a) },

      # hash with 1 key where the key is a date column and value is the column being aggegated
      ar_result_select_col_mapping: -> (v) { v.is_a?(Hash) && v.size == 1 },

      from: [Date, DateTime, Time, ActiveSupport::TimeWithZone],
      to: [Date, DateTime, Time, ActiveSupport::TimeWithZone],

      interval: -> (v) { Utils.ruby_strftime_map.keys.include?(v) }
    }

    def initialize(args)
      validate_args!(args)

      @dates_values_hash = Utils.ar_to_hash(args[:ar_result], args[:ar_result_select_col_mapping])
      @date_iterator_method = Utils::DATE_ITERATOR_METHOD_MAP[args[:interval]]

      # strformat to match the format out of the database
      @strftime_format = Utils.ruby_strftime_map[args[:interval]]

      @from = args[:from]
      @to = args[:to]
    end

    def values_and_dates
      @values_and_dates ||= array_of_dates.collect do |date, formatted_date|
        {
          date: date,
          value: Utils.to_f_or_i_or_s(@dates_values_hash[formatted_date] || 0)
        }
      end
    end

    private

    def validate_args!(hash_args)
      ClassyHash.validate(hash_args, VALID_HASH_ARGS)
      first_res = hash_args[:ar_result].first
      keys = hash_args[:ar_result_select_col_mapping].to_a.flatten
      if first_res && keys.any? { |key| !first_res.respond_to?(key) }
        raise RuntimeError.new("the collection passed does not respond to all attribs: #{keys}")
      end
    end

    def array_of_dates
      @array_of_dates ||= @from.to_date.send(@date_iterator_method, @to.to_date).map do |date|
        [date, date.strftime(@strftime_format)]
      end
    end

  end

end
