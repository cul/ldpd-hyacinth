# frozen_string_literal: true

class Types::Scalar::AnyPrimativeType < Types::BaseScalar
  description "A valid Integer, String, or Boolean"

  def self.coerce_input(input_value, _context)
    case input_value
    when String, TrueClass, FalseClass, Integer
      input_value
    else
      GraphQL::ExecutionError.new("Invalid value type: #{input_value.class.name}")
    end
  end

  def self.coerce_result(ruby_value, _context)
    case ruby_value
    when String, TrueClass, FalseClass, Integer
      ruby_value
    else
      GraphQL::ExecutionError.new("Invalid value type: #{ruby_value.class.name}")
    end
  end
end
