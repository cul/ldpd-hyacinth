# frozen_string_literal: true

module Types
  module DigitalObject
    class StructuredChildrenType < Types::BaseObject
      description 'A description of how child objects should be organized as IDs'

      field :type, String, null: false
      field :structure, [String], null: false
    end
  end
end
