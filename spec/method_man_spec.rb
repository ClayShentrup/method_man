require 'method_object'

describe MethodObject do
  subject do
    described_class.new do
      def call(
        required_arg_1,
        required_arg_2,
        optional_arg_1 = :optional_arg_1,
        optional_arg_2 = :optional_arg_2,
        &my_block)
        result << optional_arg_2 << yield(1)
      end

      def result
        [
          required_arg_1,
          required_arg_2,
          optional_arg_1,
          my_block.call(2),
        ]
      end

      def required_arg_1
        :required_arg_1
      end
    end
  end

  it 'works' do
    result = subject.call(
      required_arg_1: :required_arg_1,
      required_arg_2: :required_arg_2,
      optional_arg_1: :optional_arg_1,
      optional_arg_2: :optional_arg_2,
    ) do |block_arg|
      block_arg + 1
    end

    expect(result).to eq [
                           :required_arg_1,
                           :required_arg_2,
                           :optional_arg_1,
                           3,
                           :optional_arg_2,
                           2,
                         ]
  end

  context 'without arguments' do
    subject do
      described_class.new do
        def call
        end
      end
    end

    it 'works' do
      subject.call
    end
  end
end
