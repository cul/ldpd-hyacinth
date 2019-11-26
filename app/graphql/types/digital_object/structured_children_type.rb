# frozen_string_literal: true

module Types
  module DigitalObject
    class StructuredChildrenType < Types::BaseObject
      description 'A description of how objects should be organized'

      field :type, String, null: false
      field :structure, [String], null: false
    end
  end
end
