# frozen_string_literal: true

require('delegate')
require('method_object/version')

# See gemspec for description.
class MethodObject < SimpleDelegator
  class AmbigousMethodError < NameError; end

  class << self
    def call(**args)
      new(__object_factory__&.new(**args)).call
    end

    private(:new)

    def attrs(*attributes)
      self.__object_factory__ = ObjectFactory.create(*attributes)
    end

    attr_accessor(:__object_factory__)
  end

  def call
    raise(NotImplementedError, 'define the call method')
  end

  # Creates instances for delegation and caching method definitions.
  class ObjectFactory
    STRUCT_DEFINITION = lambda do |_class|
      def method_missing(name, *args)
        candidates = candidates_for_method_missing(name)
        handle_ambiguous_missing_method(candidates, name) if candidates.length > 1
        super
      end

      def respond_to_missing?(name, _include_private)
        candidates = candidates_for_method_missing(name)
        case candidates.length
        when 0
          return(super)
        when 1
          define_delegated_method(candidates.first)
        end
        true
      end

      def candidates_for_method_missing(method_name)
        potential_candidates =
          members.map do |attribute|
            PotentialDelegator.new(
              attribute,
              public_send(attribute),
              method_name,
            )
          end +
          members.map do |attribute|
            PotentialDelegatorWithPrefix.new(
              attribute,
              public_send(attribute),
              method_name,
            )
          end
        potential_candidates.select(&:candidate?)
      end

      def define_delegated_method(delegate)
        code = <<~RUBY
          def #{delegate.delegated_method}(*args, &block)
            #{delegate.attribute}
              .#{delegate.method_to_call_on_delegate}(*args, &block)
          end
        RUBY
        self.class.class_eval(code, __FILE__, __LINE__ + 1)
      end

      def handle_ambiguous_missing_method(candidates, method_name)
        raise(
          AmbigousMethodError,
          "#{method_name} is ambiguous: " +
          candidates
            .map do |candidate|
              "#{candidate.attribute}.#{candidate.method_to_call_on_delegate}"
            end
            .join(', '),
        )
      end
    end

    def self.create(*attributes)
      Struct.new(*attributes, keyword_init: true, &STRUCT_DEFINITION)
    end
  end

  # Represents a possible match of the form:
  #   some_method => my_attribute.some_method
  PotentialDelegator = Struct.new(:attribute, :object, :delegated_method) do
    def candidate?
      object.respond_to?(delegated_method)
    end

    alias_method(:method_to_call_on_delegate, :delegated_method)
  end

  # Represents a possible match of the form:
  #   my_attribute_some_method => my_attribute.some_method
  PotentialDelegatorWithPrefix =
    Struct.new(:attribute, :object, :delegated_method) do
      def candidate?
        name_matches? && object.respond_to?(method_to_call_on_delegate)
      end

      def method_to_call_on_delegate
        delegated_method.to_s.sub(prefix, '')
      end

      private

      def name_matches?
        delegated_method.to_s.start_with?(prefix)
      end

      def prefix
        "#{attribute}_"
      end
    end
end
