# frozen_string_literal: true

require('method_object')

RSpec.describe(MethodObject) do
  it 'makes new a private class method' do
    expect { subject.new }.to raise_error(NoMethodError)
  end

  context 'without attrs' do
    subject do
      Class.new(described_class) do
        def call
          true
        end
      end
    end

    describe 'calling a missing method' do
      subject do
        Class.new(described_class) do
          def call
            undefined_method
          end
        end
      end

      it 'raises method missing exception' do
        expect { subject.call }.to raise_error(NameError, /undefined_method/)
      end
    end

    specify { expect(subject.call).to be(true) }
  end

  context 'with attrs' do
    subject do
      Class.new(described_class) do
        attrs(:company, :user)

        def call
          self.name = 'New Company Name'
          self.company_name = 'New Company Name 2'
          {
            address: address,
            respond_to_address: respond_to_missing?(:address),
            company_address: company_address,
            id_for_joe: company_id_for('Joe'),
            block_arg: company_run_a_block { |block_arg| block_arg * 2 },
            respond_to_company_address: respond_to_missing?(:company_address),
            company: company,
            respond_to_name: respond_to_missing?(:name),
            company_name: company_name,
            respond_to_company_name: respond_to_missing?(:company_name),
            user: user,
            user_name: user_name,
            respond_to_user_name: respond_to_missing?(:user_name),
            respond_to_missing: respond_to_missing?(:undefined_method),
          }
        end
      end
    end

    let(:company) do
      double('company', address: company_address, name: company_name)
        .tap do |company|
          allow(company).to receive(:id_for).with('Joe').and_return(1234)
          allow(company).to receive(:run_a_block) do |&block|
            block.call(4321)
          end
        end
    end
    let(:company_address) { '101 Minitru Lane' }
    let(:company_name) { 'Periscope Data' }
    let(:user) { double('user', name: user_name) }
    let(:user_name) { 'Woody' }
    let(:result) { subject.call(company: company, user: user) }

    specify do
      expect(company).to receive(:name=).ordered.with('New Company Name')
      expect(company).to receive(:name=).ordered.with('New Company Name 2')
      expect(result).to eq(
        address: company_address,
        respond_to_address: true,
        company_address: company_address,
        id_for_joe: 1234,
        block_arg: 8642,
        respond_to_company_address: true,
        company: company,
        respond_to_name: false,
        company_name: company_name,
        respond_to_company_name: true,
        user: user,
        user_name: user_name,
        respond_to_user_name: true,
        respond_to_missing: false,
      )
    end

    it 'uses required keyword arguments' do
      expect { subject.call }.to raise_error(ArgumentError)
    end

    context 'with ambiguous method call' do
      subject do
        Class.new(described_class) do
          attrs(:company, :user)

          def call
            name
          end
        end
      end

      specify do
        expect { result }.to raise_error(
          MethodObject::AmbigousMethodError,
          a_string_including('company.name, user.name'),
        )
      end
    end

    context 'ambigous method call due to delegation' do
      subject do
        Class.new(described_class) do
          attrs(:company, :user)

          def call
            company_address
          end
        end
      end

      let(:user) { double('user', company_address: nil) }

      specify do
        expect { result }.to raise_error(
          MethodObject::AmbigousMethodError,
          a_string_including('user.company_address, company.address'),
        )
      end
    end

    describe 'respecting method privacy' do
      let(:subject) do
        Class.new(described_class) do
          attrs(:diary)

          def call
            diary_contents
          end
        end
      end
      let(:diary) do
        Module.new do
          def self.contents; end

          private_class_method(:contents)
        end
      end

      specify do
        expect { subject.call(diary: diary) }.to raise_error(StandardError)
      end
    end

    describe '"memoizes" method calls' do
      subject do
        Class.new(described_class) do
          attrs(:company)
          @sent_messages = []

          class << self
            attr_reader(:sent_messages)
          end

          def call
            [name, name]
          end

          # Ensure it defines resolved methods
          def method_missing(method, *_args)
            if self.class.sent_messages.include?(method)
              raise 'method not memoized'
            end
            self.class.sent_messages << method
            super
          end
        end
      end

      specify do
        expect(subject.call(company: company))
          .to eq([company_name, company_name])
      end
    end
  end

  context 'without a provided instance call method' do
    subject do
      Class.new(described_class) { attrs(:user_1_age) }
    end

    specify do
      expect { subject.call(user_1_age: user_1_age) }.to raise_error(NameError)
    end
  end
end
