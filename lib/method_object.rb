require 'method_object/version'

class MethodObject
  def self.new(*args, &block)
    super(*args, block).call
  end

  def initialize(*required_keyword_args, block)
    @required_keyword_args = required_keyword_args
    @block = block
  end

  def call
    code = self.code
    block = @block

    Struct.new(*@required_keyword_args) do
      private_class_method :new
      eval(code)
      def call
        fail NotImplementedError, "Please define the call method"
      end
      class_eval(&block)
    end
  end

  def code
    <<-CODE
      def self.call(#{required_keyword_args_string})
        new(#{ordered_args_string}).call
      end
    CODE
  end

  def required_keyword_args_string
    @required_keyword_args.map { |arg| "#{arg}:" }.join(',')
  end

  def ordered_args_string
    @required_keyword_args.join(',')
  end
end
