# frozen_string_literal: true

class Types::Scalar::Limit < Types::BaseScalar
  MIN = 1
  MAX = 100

  description "An Integer between #{MIN} and #{MAX}"

  def self.coerce_input(input_value, _context)
    if input_value.is_a?(Integer)
      if input_value.between?(MIN, MAX)
        input_value
      else
        GraphQL::ExecutionError.new("Limit must be between #{MIN} and #{MAX}")
      end
    else
      GraphQL::ExecutionError.new("Invalid value type: #{input_value.class.name}")
    end
  end

  def self.coerce_result(ruby_value, _context)
    if ruby_value.is_a?(Integer)
      if ruby_value.between?(MIN, MAX)
        ruby_value
      else
        GraphQL::ExecutionError.new("Limit must be between #{MIN} and #{MAX}")
      end
    else
      GraphQL::ExecutionError.new("Invalid value type: #{ruby_value.class.name}")
    end
  end
end
