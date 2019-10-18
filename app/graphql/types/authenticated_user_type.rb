module Types
  class AuthenticatedUserType < Types::BaseObject
    description 'A user with rules'
    field :id, String, null: false, method: :uid
    field :email, String, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :is_active, Boolean, null: true
    field :is_admin, Boolean, null: true
    field :rules, [RuleType], null: true, resolver_method: :rules

    def rules
      Ability.new(object).to_list
    end
  end
end
