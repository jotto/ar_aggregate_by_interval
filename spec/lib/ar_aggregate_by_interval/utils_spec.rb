require 'ar_aggregate_by_interval/utils'
require 'ostruct'

module ArAggregateByInterval

  describe Utils do

    context 'converting ar to hash' do

      subject do
        described_class.ar_to_hash(ar_objs, mapping)
      end

      context 'normal values' do
        let(:ar_objs) do
          [
            OpenStruct.new({
              date_chunk__: '2014-01-01',
              value: 5
            })
          ]
        end

        let(:mapping) { { 'date_chunk__' => 'value' } }

        it 'works' do
          expect(subject).to eq({ '2014-01-01' => 5 })
        end
      end

      context 'arbitrary values' do
        let(:ar_objs) do
          [
            OpenStruct.new({
              id: OpenStruct.new({}),
              something: 1
            })
          ]
        end
        let(:mapping) { { 'id' => 'something' } }

        it 'does not cast or change any objects' do
          expect(subject.keys.first).to be_a(OpenStruct)
          expect(subject.values.first).to be_a(Integer)
        end
      end

    end
  end

end