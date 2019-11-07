module Types
  class RuleType < Types::BaseObject
    description 'A CanCan Rule'
    field :actions, [String], null: false
    field :subject, [String], null: true
    field :conditions, GraphQL::Types::JSON, null: true
    field :inverted, String, null: true
  end
end
