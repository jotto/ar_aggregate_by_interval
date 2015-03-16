module ArAggregateByInterval
  module Utils

    extend self

    DATE_ITERATOR_METHOD_MAP = {
      'monthly' => 'each_month_until',
      'weekly' => 'each_week_until',
      'daily' => 'each_day_until'
    }

    # support legacy arguments (as opposed to direct hash)
    # can do:
    # ArModel.count_weekly(:group_by_col, :from, :to, :return_dates_bool)
    # ArModel.count_weekly(:from, :to, :return_dates_bool) # defaults to :created_at
    # or
    # ArModel.sum_weekly(:group_by_col, :aggregate_col, :from, :to, :return_dates_bool)
    def args_to_hash(sum_or_count, daily_weekly_monthly, *args)
      group_by_column, aggregate_column, from, to, return_dates = args

      group_by_column ||= 'created_at'
      return_dates ||= false

      if sum_or_count == 'count'
        if aggregate_column.present? && (aggregate_column.is_a?(Date) || aggregate_column.is_a?(Time))
          return_dates = to
          to = from
          from = aggregate_column
          aggregate_column = nil
        end
      elsif sum_or_count != 'count' && aggregate_column.nil? || !(aggregate_column.is_a?(String) || aggregate_column.is_a?(Symbol))
        raise ArgumentError, "aggregate_column cant be nil with #{sum_or_count}"
      end

      return {
        group_by_column: group_by_column.try(:intern),
        from: from,
        to: to,
        aggregate_column: aggregate_column.try(:intern)
      }.delete_if { |k, v| v.nil? }
    end

    def ar_to_hash(ar_result, mapping)
      ar_result.to_a.inject({}) do |memo, ar_obj|
        mapping.each { |key, val| memo.merge!(ar_obj.send(key).to_s => ar_obj.send(val)) }
        memo
      end
    end

    def ruby_strftime_map
      {
        'monthly' => '%Y-%m',
        # sqlite doesn't support ISO weeks
        'weekly' => Utils.db_vendor.match(/sqlite/i) ? '%Y-%U' : '%G-%V',
        'daily' => '%F'
      }
    end

    def select_for_grouping_column(grouping_col)
      case db_vendor
      when /mysql/i
        {
          'monthly' => "date_format(#{grouping_col}, '%Y-%m')",
          'weekly' => "date_format(#{grouping_col}, '%x-%v')",
          'daily' => "date(#{grouping_col})"
        }
      when /postgres/i
        {
          'monthly' => "to_char(#{grouping_col}, 'YYYY-MM')",
          'weekly' => "to_char(#{grouping_col}, 'IYYY-IW')",
          'daily' => "date(#{grouping_col})"
        }
      when /sqlite/i
        {
          'monthly' => "strftime('%Y-%m', #{grouping_col})",
          'weekly' => "strftime('%Y-%W', #{grouping_col})", # sqlite doesn't support ISO weeks
          'daily' => "date(#{grouping_col})"
        }
      else
        raise "unknown database vendor #{db_vendor}"
      end
    end

    def db_vendor
      ActiveRecord::Base.connection_config.try(:symbolize_keys).try(:[], :adapter) ||
      ENV['DATABASE_URL']
    end

    # converts args like: [weekly, beginning] to beginning_of_week
    def interval_inflector(interval, beg_or_end)
      raise "beginning or end, not #{beg_or_end}" unless beg_or_end.match(/\A(beginning|end)\z/)

      time_interval = {
        'monthly' => 'month',
        'weekly' => 'week',
        'daily' => 'day'
      }[interval] || raise("unknown interval #{interval}")

      "#{beg_or_end}_of_#{time_interval}"
    end

    def to_f_or_i_or_s(v)
      ((float = Float(v)) && (float % 1.0 == 0) ? float.to_i : float) rescue v
    end

  end
end
