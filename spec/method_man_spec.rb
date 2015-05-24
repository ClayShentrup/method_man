require 'method_object'

describe MethodObject do
  subject do
    described_class.new(:value_one, :value_two) do
      def call
        value_one + value_two
      end
    end
  end

  let(:value_one) { 1 }
  let(:value_two) { 2 }
  let(:actual_result) do
    subject.call(value_one: value_one, value_two: value_two)
  end

  it 'works' do
    expect(actual_result).to eq 3
  end

  it 'uses required keyword arguments' do
    expect { subject.call }.to raise_error ArgumentError
  end

  it 'makes new a private class method' do
    expect { subject.new }.to raise_error NoMethodError
  end

  context 'without a provided instance call method' do
    subject { described_class.new(:value_one) {} }

    it 'raises an error' do
      expect { subject.call(value_one: value_one) }
        .to raise_error NotImplementedError
    end
  end
end
