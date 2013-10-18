class MethodObject::Base
  class << self
    private :new

    def call(options, &block)
      new(
        options,
        block,
        @generator)
      .call(*arguments_from_options(options), &block)
    end

    private

    def arguments_from_options(options)
      options.values_at(*@generator.non_block_parameter_names)
    end
  end

  def initialize(options, block, generator)
    options.each do |parameter_name, value|
      instance_variable_set("@#{parameter_name}", value)
    end
    instance_variable_set("@#{generator.block_name}", block)
  end
end
