require 'method_object/version'
require 'method_object/base'

class MethodObject
  def self.new
    super.call
  end

  def initialize(&definition_block)
    @definition_block = definition_block
  end

  def call
    add_generator
    add_getters
    method_object_class
  end

  def block_name
    block_parameter.fetch(1)
  end

  def non_block_parameter_names
    @non_block_parameter_names ||= non_block_parameters.map { |parameter| parameter.fetch(1) }
  end

  private

  def add_generator
    method_object_class.instance_variable_set(:@generator, self)
  end

  def method_object_class
    @method_object_class ||= Class.new(Base, &@definition_block)
  end
  
  def add_getters
    add_parameter_getters
    add_block_getter
  end

  def add_parameter_getters
    non_block_parameter_names.each do |parameter_name|
      method_object_class.send(:attr_reader, parameter_name)
    end
  end

  def add_block_getter
    method_object_class.send(:attr_reader, block_name)
  end

  def block_parameter
    @block_parameter ||= parameters.find { |parameter| parameter[0] == :block }
  end

  def parameters
    method_object_class.instance_method(:call).parameters
  end

  def non_block_parameters
    parameters - [block_parameter]
  end
end
