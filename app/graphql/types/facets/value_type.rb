# frozen_string_literal: true

module Types
  module Facets
    class ValueType < Types::BaseObject
      description 'A value and the count of matching documents in the results scope'

      field :value, String, null: false
      field :count, Integer, null: false
    end
  end
end
