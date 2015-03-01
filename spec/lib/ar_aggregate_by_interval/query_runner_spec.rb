require 'ar_aggregate_by_interval/query_runner'

module ArAggregateByInterval
  describe QueryRunner do

    subject do
      described_class.new(Blog, {
        aggregate_function: aggregate_function,
        aggregate_column: (aggregate_column rescue nil),
        interval: interval,
        group_by_column: :created_at,
        from: from,
        to: to
      })
    end

    context 'one week duration' do

      # monday
      let(:from) { DateTime.parse '2013-08-05' }
      # sunday
      let(:to) { DateTime.parse '2013-08-11' }

      before do |example|
        Blog.create [
          {arbitrary_number: 10, created_at: from},
          {arbitrary_number: 20, created_at: from}
        ]
      end

      context 'avg daily' do
        let(:interval) { 'daily' }
        let(:aggregate_function) { 'avg' }
        let(:aggregate_column) { :arbitrary_number }

        describe '.values' do
          it 'returns an array of size 7' do
            expect(subject.values.size).to eq 7
          end
          it 'returns actual averages' do
            expect(subject.values).to eq([15, 0, 0, 0, 0, 0, 0])
          end
        end
      end

      context 'count weekly' do
        let(:interval) { 'weekly' }
        let(:aggregate_function) { 'count' }

        describe '.values' do
          it 'returns exactly 1 element array with 1' do
            expect(subject.values).to eq([2])
          end
        end

        describe '.value_and_dates' do
          it 'returns value and date with expected values' do
            expect(subject.values_and_dates).to eq([date: from.beginning_of_week.to_date, value: 2])
          end
        end
      end

    end
  end

end
