# frozen_string_literal: true
require 'method_object/version'

# See gemspec for description
class MethodObject
  class AmbigousMethodError < NameError; end

  class << self
    def attrs(*attributes)
      @attributes = attributes
      Setup.call(attributes: attributes, subclass: self)
    end

    def call(**args)
      new(args).call
    end

    attr_reader(:attributes)

    private(:new)
  end

  def initialize(_); end

  def call
    raise NotImplementedError, 'Define the call method'
  end

  def method_missing(name, *args, &block)
    candidates = candidates_for_method_missing(name)
    case candidates.length
    when 0
      super
    when 1
      define_and_call_new_method(candidates.first)
    else
      handle_ambiguous_missing_method(candidates, name)
    end
  end

  def respond_to_missing?(name)
    candidates_for_method_missing(name).length == 1
  end

  def candidates_for_method_missing(method_name)
    potential_candidates =
      self.class.attributes.map do |attribute|
        PotentialDelegator.new(attribute, send(attribute), method_name)
      end +
      self.class.attributes.map do |attribute|
        PotentialDelegatorWithPrefix.new(
          attribute,
          send(attribute),
          method_name,
        )
      end
    potential_candidates.select(&:candidate?)
  end

  def define_and_call_new_method(candidate)
    self.class.class_eval(
      <<-RUBY
        def #{candidate.delegated_method}
          #{candidate.attribute}.#{candidate.method_to_call_on_delegate}
        end
      RUBY
    )
    public_send(candidate.delegated_method)
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

  # Represents a possible match of the form:
  #   some_method => my_attribute.some_method
  PotentialDelegator = Struct.new(:attribute, :object, :delegated_method) do
    def candidate?
      object.respond_to?(delegated_method)
    end

    def call
      object.public_send(delegated_method)
    end

    alias_method :method_to_call_on_delegate, :delegated_method
  end

  # Represents a possible match of the form:
  #   my_attribute_some_method => my_attribute.some_method
  PotentialDelegatorWithPrefix =
    Struct.new(:attribute, :object, :delegated_method) do
      def candidate?
        name_matches? && object.respond_to?(method_to_call_on_delegate)
      end

      def call
        object.public_send(method_to_call_on_delegate)
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

  # Dynamically defines custom attr_readers and initializer
  class Setup < SimpleDelegator
    def self.call(attributes:, subclass:)
      new(attributes, subclass).call
    end

    attr_accessor(:attributes)

    def initialize(attributes, subclass)
      self.attributes = attributes
      super(subclass)
    end

    def call
      define_attr_readers
      define_initializer
    end

    private

    def define_attr_readers
      __getobj__.send(:attr_reader, *attributes)
    end

    def attr_accessor(attribute)
      super
    end

    def define_initializer
      class_eval(
        <<-RUBY
          def initialize(#{required_keyword_args_string})
            #{assignments}
          end
        RUBY
      )
    end

    def required_keyword_args_string
      attributes.map { |arg| "#{arg}:" }.join(',')
    end

    def assignments
      attributes.map { |attribute| "@#{attribute} = #{attribute}\n" }.join
    end
  end
end
