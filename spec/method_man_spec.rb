# frozen_string_literal: true

require('method_object')
require('ostruct')

RSpec.describe(MethodObject) do
  context('with attrs') do
    let(:method_object) do
      Class.new(described_class) do
        attrs(:block, :attr1, :attr2)

        def call
          instance_eval(&block)
        end

        def local_method
          [attr1, attr2]
        end
      end
    end
    let(:attr1) { double('attr1', ambiguous_method: nil, delegated_method: delegated_value) }
    let(:delegated_value) { 'delegated value' }
    let(:attr2) do
      double('attr2', ambiguous_method: nil, attr1_ambiguous_method: nil)
    end

    def call(&block)
      method_object.call(block: block, attr1: attr1, attr2: attr2)
    end

    def delegates?(method)
      call { respond_to?(method) }
    end

    it('makes .new a private class method') do
      expect { method_object.new }.to(raise_error(NoMethodError))
    end

    it('raises method missing exception for undefined methods') do
      expect { call { undefined_method } }.to(raise_error(NameError, /undefined_method/))
    end

    it('calls its own methods and passed attrs') do
      expect(call { local_method }).to(eq([attr1, attr2]))
    end

    it('delegates to attrs') do
      expect(delegates?(:delegated_method)).to(be(true))

      expect(call { delegated_method }).to(be(delegated_value))
    end

    it('caches methods delegated to attrs') do
      call { delegated_method }
      expect(call { defined?(delegated_method) }).to eq('method')
      expect(call { delegated_method }).to(be(delegated_value))
    end

    it('delegates to attrs with prefix') do
      expect(delegates?(:attr1_delegated_method)).to(be(true))

      expect(call { attr1_delegated_method }).to(be(delegated_value))
    end

    it('caches methods delegated to attrs with prefix') do
      call { delegated_method }
      expect(call { defined?(attr1_delegated_method) }).to eq('method')
      expect(call { attr1_delegated_method }).to(be(delegated_value))
    end

    it('raises for ambiguity on delegated method names') do
      expect(delegates?(:ambiguous_method)).to(be(true))

      expect { call { ambiguous_method } }.to(
        raise_error(
          MethodObject::AmbigousMethodError,
          a_string_including('ambiguous_method is ambiguous: attr1.ambiguous_method, attr2.ambiguous_method'),
        ),
      )
    end

    it('raises for ambiguity on delegated and prefixed delegated method names') do
      expect(delegates?(:attr1_ambiguous_method)).to(be(true))

      expect { call { attr1_ambiguous_method } }.to(
        raise_error(
          MethodObject::AmbigousMethodError,
          a_string_including(
            'attr1_ambiguous_method is ambiguous: ' \
            'attr2.attr1_ambiguous_method, attr1.ambiguous_method',
          ),
        ),
      )
    end

    describe('assignments') do
      let(:attr1) { OpenStruct.new }

      it('assigns') do
        call { attr1.foo = 'bar' }
        expect(attr1.foo).to(eq('bar'))
      end
    end
  end

  context('without attrs') do
    let(:method_object) do
      Class.new(described_class) do
        def call
          receiver_test
        end

        def receiver_test
          42
        end
      end
    end

    def call
      method_object.call
    end

    it 'makes new a private class method' do
      expect { method_object.new }.to raise_error(NoMethodError)
    end

    it('calls itself') do
      expect(call { receiver_test }).to eq(42)
    end
  end
end
