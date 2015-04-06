require 'active_support'
require 'active_support/core_ext'
require 'classy_hash'
require 'date_iterator'
require 'ar_aggregate_by_interval/utils'

module ArAggregateByInterval

  class QueryResult

    VALID_HASH_ARGS = {
      date_values_hash: [Hash],

      from: [Date, DateTime, Time, ActiveSupport::TimeWithZone],
      to: [Date, DateTime, Time, ActiveSupport::TimeWithZone],

      interval: -> (v) { Utils.ruby_strftime_map.keys.include?(v) }
    }

    def initialize(hash_args)
      ClassyHash.validate(hash_args, VALID_HASH_ARGS)

      @dates_values_hash = hash_args[:date_values_hash]
      @date_iterator_method = Utils::DATE_ITERATOR_METHOD_MAP[hash_args[:interval]]

      # strformat to match the format out of the database
      @strftime_format = Utils.ruby_strftime_map[hash_args[:interval]]

      @from = hash_args[:from]
      @to = hash_args[:to]
    end

    def values_and_dates
      @values_and_dates ||= array_of_dates.collect do |date, formatted_date|
        {
          date: date,
          value: Utils.to_f_or_i_or_s(@dates_values_hash[formatted_date] || 0)
        }
      end
    end

    def values
      @values ||= values_and_dates.collect { |hash| hash[:value] }
    end

    private

    def array_of_dates
      @array_of_dates ||= @from.to_date.send(@date_iterator_method, @to.to_date).map do |date|
        [date, date.strftime(@strftime_format)]
      end
    end

  end

end
