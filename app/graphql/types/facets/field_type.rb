# frozen_string_literal: true

module Types
  module Facets
    class FieldType < Types::BaseObject
      description 'A labeled field and the values characterizing the results scope'

      field :field_name, String, null: false
      field :display_label, String, null: false
      field :values, [Types::Facets::ValueType], null: false
    end
  end
end
