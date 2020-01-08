# frozen_string_literal: true

class Types::Scalar::Offset < Types::BaseScalar
  MIN = 0

  description "A positive Integer, including zero"

  def self.coerce_input(input_value, _context)
    if input_value.is_a?(Integer)
      if input_value >= MIN
        input_value
      else
        GraphQL::ExecutionError.new("Offset must be a positive integer")
      end
    else
      GraphQL::ExecutionError.new("Invalid value type: #{input_value.class.name}")
    end
  end

  def self.coerce_result(ruby_value, _context)
    if ruby_value.is_a?(Integer)
      if ruby_value >= MIN
        ruby_value
      else
        GraphQL::ExecutionError.new("Offset must be a positive integer")
      end
    else
      GraphQL::ExecutionError.new("Invalid value type: #{ruby_value.class.name}")
    end
  end
end
