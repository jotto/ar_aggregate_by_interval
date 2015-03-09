require 'ar_aggregate_by_interval'

describe ArAggregateByInterval do

  before(:all) do |example|
    @from = DateTime.parse '2013-08-05'
    @to = @from
    blog1 = Blog.create arbitrary_number: 10, created_at: @from
    blog2 = Blog.create arbitrary_number: 20, created_at: @from
    blog1.page_views.create date: @from
    blog1.page_views.create date: @from
  end

  shared_examples_for 'count .values_and_dates' do
    it 'returns value and date with expected values' do
      expect(subject.values_and_dates).to eq([date: @from.beginning_of_week.to_date, value: 2])
    end
  end

  shared_examples_for 'sum .values_and_dates' do
    it 'returns value and date with expected values' do
      expect(subject.values_and_dates).to eq([date: @from.beginning_of_week.to_date, value: 30])
    end
  end

  shared_examples_for 'avg .values_and_dates' do
    it 'returns value and date with expected values' do
      expect(subject.values_and_dates).to eq([date: @from.beginning_of_week.to_date, value: 15])
    end
  end

  context 'ActiveRecord::Relation scoped' do
    subject do
      # `where` returns ActiveRecord::Relation
      Blog.where('id > 0').count_weekly(:created_at, @from, @from)
    end
    it_behaves_like 'count .values_and_dates'
  end

  context 'Array scoped' do
    subject do
      # `associations` return arrays
      Blog.first.page_views.count_weekly(:date, @from, @from)
    end
    it_behaves_like 'count .values_and_dates'
  end

  context 'hash args' do

    context 'for count' do
      subject do
        Blog.count_weekly({
          group_by_column: :created_at,
          from: @from,
          to: @to
        })
      end
      it_behaves_like 'count .values_and_dates'
    end

    context 'for sum' do
      subject do
        Blog.sum_weekly({
          group_by_column: :created_at,
          aggregate_column: :arbitrary_number,
          from: @from,
          to: @to
        })
      end
      it_behaves_like 'sum .values_and_dates'

      context 'with strings' do
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

    context 'for avg' do
      subject do
        Blog.avg_weekly({
          group_by_column: :created_at,
          aggregate_column: :arbitrary_number,
          from: @from,
          to: @to
        })
      end
      it_behaves_like 'avg .values_and_dates'
    end

  end

  context 'normal args' do
    context 'for count' do
      subject do
        Blog.count_weekly(:created_at, @from, @from)
      end
      it_behaves_like 'count .values_and_dates'
    end
    context 'for sum' do
      subject do
        Blog.sum_weekly(:created_at, :arbitrary_number, @from, @from)
      end
      it_behaves_like 'sum .values_and_dates'

      context 'with strings' do
        subject do
          Blog.sum_weekly('created_at', 'arbitrary_number', @from, @from)
        end
        it_behaves_like 'sum .values_and_dates'
      end
    end
    context 'for avg' do
      subject do
        Blog.avg_weekly(:created_at, :arbitrary_number, @from, @from)
      end
      it_behaves_like 'avg .values_and_dates'
    end
  end

  context 'bad args' do
    context 'for count' do
      subject do
        Blog.count_weekly(:created_at, {}, {})
      end
      it 'raise ArgumentError' do
        expect do
          subject
        end.to raise_error(ArgumentError)
      end
    end

    context 'for sum' do
      subject do
        Blog.sum_weekly(:created_at, @from, @from)
      end
      it 'raise ArgumentError' do
        expect do
          subject
        end.to raise_error(ArgumentError, /aggregate_column/)
      end
    end
  end

end
