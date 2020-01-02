# frozen_string_literal: true

module Types
  class RuleType < Types::BaseObject
    description 'A CanCan Rule'

    field :actions, [String], null: false
    field :subject, [String], null: false
    field :conditions, GraphQL::Types::JSON, null: false, resolver_method: :conditions
    field :inverted, Boolean, null: false

    # Keys in the conditions need to be in camelCase.
    def conditions
      object[:conditions].deep_transform_keys { |k| k.to_s.camelize(:lower) }
    end
  end
end
