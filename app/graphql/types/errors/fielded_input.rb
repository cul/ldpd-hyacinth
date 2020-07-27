# frozen_string_literal: true

module Types
  module Errors
    class FieldedInput < Types::BaseObject
      description 'An error message related to input for a field by path'

      field :message, String, null: false, description: "A description of the error"
      field :path, [String], null: true,
        description: "field path for the input value this error came from"
    end
  end
end
