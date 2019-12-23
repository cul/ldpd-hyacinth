# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    description 'A user'
    field :id, String, null: false, method: :uid
    field :email, String, null: false
    field :first_name, String, null: false
    field :middle_name, String, null: true
    field :last_name, String, null: false
    field :full_name, String, null: false
    field :sort_name, String, null: false
    field :is_active, Boolean, null: true
    field :is_admin, Boolean, null: true
    field :permissions, [String], null: true

    def permissions
      object.system_wide_permissions.map(&:action)
    end
  end
end
