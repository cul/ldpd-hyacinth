module Types
  class RuleType < Types::BaseObject
    description 'A CanCan Rule'
    field :action, String, null: false
    field :subject, [String], null: true
    field :conditions, String, null: true
    field :inverted, String, null: true
  end
end
