module Types
  class UserType < Types::BaseObject
    description 'A user'
    field :id, String, null: false, method: :uid
    field :email, String, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :is_active, Boolean, null: true
    field :is_admin, Boolean, null: true
    field :password, String, null: true
    field :password_confirmation, String, null: true
    field :permissions, [String], null: true

    def permissions
      object.system_wide_permissions.map(&:action)
    end
  end
end