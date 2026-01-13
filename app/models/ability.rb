# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.admin?
      # Hyacinth admins can perform any action on any User record
      # :manage includes :index, :show, :create, :update, :destroy, etc.
      can :manage, User
    else
      # Non-admin users can only view and update their own user record
      # Explicitly using :show and :update (not :read) so :index is not included
      can [:show, :update, :generate_api_key, :read_project_permissions], User, id: user.id
      
      # Only Hyacinth admins can update project permissions
      cannot :update_project_permissions, User
    end
  end
end
