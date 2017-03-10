require 'method_object/version'

class MethodObject
  class << self
    def attrs(*attributes)
      define_attr_accessors(attributes)
      define_setup_methods(attributes)
    end

    private

    def define_attr_accessors(attributes)
      attributes.each { |attribute| send(:attr_accessor, attribute) }
    end

    def define_setup_methods(attributes)
      instance_eval(
        <<-CODE
          def self.call(**args)
            new(args).call
          end

          private_class_method :new
        CODE
      )

      class_eval(
        <<-CODE
          def initialize(#{required_keyword_args_string(attributes)})
            #{keyword_arg_instance_variables(attributes)} =
              #{ordered_args_string(attributes)}
          end

          def call
            fail NotImplementedError, "Please define the call method"
          end
        CODE
      )
    end

    def required_keyword_args_string(attributes)
      attributes.map { |arg| "#{arg}:" }.join(', ')
    end

    def ordered_args_string(attributes)
      attributes.join(',')
    end

    def keyword_arg_instance_variables(attributes)
      attributes.map { |attribute| "@#{attribute}" }.join(', ')
    end
  end
end
