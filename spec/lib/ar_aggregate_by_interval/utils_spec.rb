require 'ar_aggregate_by_interval/utils'
require 'ostruct'

module ArAggregateByInterval

  describe Utils do

    describe 'interval_inflector' do

      shared_examples 'working inflector' do |int, beg_end, expected|
        it "works for #{beg_end}_#{int}" do
          expect(described_class.interval_inflector(int, beg_end)).to eq expected
        end
      end

      include_examples 'working inflector', 'daily', 'beginning', 'beginning_of_day'
      include_examples 'working inflector', 'daily', 'end', 'end_of_day'

      include_examples 'working inflector', 'weekly', 'beginning', 'beginning_of_week'
      include_examples 'working inflector', 'weekly', 'end', 'end_of_week'

      include_examples 'working inflector', 'monthly', 'beginning', 'beginning_of_month'
      include_examples 'working inflector', 'monthly', 'end', 'end_of_month'

    end

    describe 'to_f_or_i_or_s' do

      shared_examples 'working Numeric converter' do |arg1, expected_class|
        it "works for #{arg1.class.name} to #{expected_class.name}" do
          expect(described_class.to_f_or_i_or_s(arg1)).to be_instance_of(expected_class)
        end
      end

      include_examples 'working Numeric converter', '1.1', Float
      include_examples 'working Numeric converter', 1.1, Float
      include_examples 'working Numeric converter', '1.0', Fixnum
      include_examples 'working Numeric converter', 1.0, Fixnum
      include_examples 'working Numeric converter', 1, Fixnum

    end

  end

end
