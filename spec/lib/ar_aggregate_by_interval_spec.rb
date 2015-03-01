require 'active_record'
require 'ar_aggregate_by_interval'
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load File.join(File.dirname(__FILE__), '../schema.rb')

class Blog < ActiveRecord::Base; end

describe ArAggregateByInterval do

  before(:all) do |example|
    @from = DateTime.parse '2013-08-05'
    @to = @from
    Blog.create arbitrary_number: 10, created_at: @from
  end

  shared_examples_for 'count .values_and_dates' do
    it 'returns value and date with expected values' do 
      expect(subject.values_and_dates).to eq([date: @from.beginning_of_week.to_date, value: 1])
    end
  end

  shared_examples_for 'sum .values_and_dates' do
    it 'returns value and date with expected values' do 
      expect(subject.values_and_dates).to eq([date: @from.beginning_of_week.to_date, value: 10])
    end
  end

  context 'scoped' do
    subject do
      Blog.where('id > 0').count_weekly('created_at', @from, @from)
    end
    it_behaves_like 'count .values_and_dates'
  end

  context 'hash args' do

    context 'for count' do
      subject do
        Blog.count_weekly({
          group_by_column: 'created_at',
          from: @from,
          to: @to
        })
      end
      it_behaves_like 'count .values_and_dates'
    end

    context 'for sum' do
      subject do
        Blog.sum_weekly({
          group_by_column: 'created_at',
          aggregate_column: 'arbitrary_number',
          from: @from,
          to: @to
        })
      end
      it_behaves_like 'sum .values_and_dates'
    end

  end

  context 'normal args' do
    context 'for count' do
      subject do
        Blog.count_weekly('created_at', @from, @from)
      end
      it_behaves_like 'count .values_and_dates'
    end
    context 'for sum' do
      subject do
        Blog.sum_weekly('created_at', 'arbitrary_number', @from, @from)
      end
      it_behaves_like 'sum .values_and_dates'
    end
  end

  context 'bad args' do
    context 'for count' do
      subject do
        Blog.count_weekly('created_at', {}, {})
      end
      it 'raise NoMethodError' do
        expect do
          subject
        end.to raise_error(NoMethodError)
      end
    end

    context 'for sum' do
      subject do
        Blog.sum_weekly('created_at', @from, @from)
      end
      it 'raise NoMethodError' do
        expect do
          subject
        end.to raise_error(RuntimeError, /aggregate_column/)
      end
    end
  end

end