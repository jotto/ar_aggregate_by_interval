require 'ar_aggregate_by_interval/query_runner'
require 'active_record'
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load File.join(File.dirname(__FILE__), '../../schema.rb')

class Blog < ActiveRecord::Base; end

module ArAggregateByInterval
  describe QueryRunner do

    subject do
      described_class.new(Blog, {
        aggregate_function: 'count',
        interval: 'weekly',
        group_by_column: 'created_at',
        from: from,
        to: to
      })
    end

    context 'this week only' do

      before do |example|
        Blog.create arbitrary_number: 10, created_at: from
      end

      let(:from) { DateTime.parse '2013-08-05' }
      let(:to) { from }

      describe '.values' do
        it 'returns exactly 1 element array with 1' do
          expect(subject.values).to eq([1])
        end
      end

      describe '.value_and_dates' do
        it 'returns value and date with expected values' do 
          expect(subject.values_and_dates).to eq([date: from.beginning_of_week.to_date, value: 1])
        end
      end
    end
  end

end