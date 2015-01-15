
# adds count_daily, count_weekly, count_monthly to AR models
# Blog.count_weekly(date_group_col = :created_at, aggregate_col = nil, from = 6.months.ago, to = nil)
# POSTGRES AND MYSQL COMPATIBLE
module ArAggregateCounter
  extend ActiveSupport::Concern
  # module ClassMethods
    def method_missing(method_name, *args)
      tokenized_method = method_name.to_s.scan(/\A(sum|count)_(daily|weekly|monthly)\z/).flatten
      return super unless tokenized_method.size == 2 && tokenized_method.all?{|chunk|chunk.present?}
      aggregate_counter(*[*tokenized_method, *args])
    end
    def aggregate_counter(sum_or_count, daily_weekly_monthly, date_group_col = :created_at, aggregate_col = nil, from = nil, to = nil)
      if sum_or_count == "count"
        if aggregate_col.present? && (aggregate_col.is_a?(Date) || aggregate_col.is_a?(Time))
          to = from
          from = aggregate_col
          aggregate_col = nil
        end
      elsif sum_or_count != "count" && aggregate_col.nil? || !(aggregate_col.is_a?(String) || aggregate_col.is_a?(Symbol))
        raise "aggregate_col cant be nil with #{sum_or_count}"
      end

      # # postgres test
      # r=10.years.ago.beginning_of_year.to_date.each_day_until(Time.now.to_date).reject do |_date|
      #   ActiveRecord::Base.connection.execute("select to_char('#{_date.to_date.to_s}'::date, 'IYYY-IW') as res;").first["res"] == _date.strftime("%G-%V")
      # end
      # 
      # # mysql test
      # r=10.years.ago.beginning_of_year.to_date.each_day_until(Time.now.to_date).reject do |_date|
      #   ActiveRecord::Base.connection.execute("select date_format('#{_date.to_date.to_s}','%x-%v')").to_a.first.first == _date.strftime("%G-%V")
      # end

      daily_weekly_monthly = daily_weekly_monthly.to_sym

      rubystrftime = {:monthly => '%Y-%m', :weekly => '%G-%V', :daily => '%F'}
      date_iterator = {:monthly => "each_month_until", :weekly => "each_week_until", :daily => "each_day_until"}

      date_format = case (Rails.configuration.database_configuration.try(:[], Rails.env).try(:[],'adapter') || ENV["DATABASE_URL"])
      when /mysql/i
        {
          :monthly => "date_format(#{date_group_col}, '%Y-%m')",
          :weekly => "date_format(#{date_group_col}, '%x-%v')",
          :daily => "date(#{date_group_col})"
        }
      when /postgres/i
        {
          :monthly => "to_char(#{date_group_col}, 'YYYY-MM')",
          :weekly => "to_char(#{date_group_col}, 'IYYY-IW')",
          :daily => "date(#{date_group_col})"
        }
      end

      from ||= 3.months.ago
      case daily_weekly_monthly.to_s
      when "monthly"
        from = from.beginning_of_month
      when "weekly"
        from = from.beginning_of_week
      when "daily"
        from = from.beginning_of_day
      end
      to ||= Time.now
      from = from.to_date
      to = to.to_date

      _scope = self.
        select("#{sum_or_count}(#{aggregate_col || '*'}) as totalchunked__").
        select("#{date_format[daily_weekly_monthly]} as datechunk__").
        group("datechunk__").
        where(["#{date_group_col} >= ? and #{date_group_col} <= ?", from, to])

      res = _scope.to_a
      array_of_numbers = from.to_date.send(date_iterator[daily_weekly_monthly]).collect do |month_date_object|
        _rb_datechunk = month_date_object.strftime(rubystrftime[daily_weekly_monthly])
        res.find{|row|row.datechunk__.to_s == _rb_datechunk.to_s}.try(:totalchunked__) || 0
      end

      array_of_numbers.collect!(&:to_i) if sum_or_count == "count"

      array_of_numbers
    end
  # end
end

# ActiveRecord::Base.send(:include, ArAggregateCounter)
ActiveRecord::Base.send :extend, ArAggregateCounter
ActiveRecord::Relation.send :include, ArAggregateCounter