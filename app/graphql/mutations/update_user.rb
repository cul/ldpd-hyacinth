# frozen_string_literal: true

class Mutations::UpdateUser < Mutations::BaseMutation
  argument :id, ID, required: true
  argument :first_name, String, required: false
  argument :last_name, String, required: false
  argument :email, String, required: false
  argument :current_password, String, required: false
  argument :password, String, required: false
  argument :password_confirmation, String, required: false
  argument :is_active, Boolean, required: false
  argument :is_admin, Boolean, required: false
  argument :permissions, [String], required: false

  field :user, Types::UserType, null: true

  def resolve(id:, **attributes)
    user = User.find_by!(uid: id)

    ability.authorize! :update, user

    permissions = attributes.delete(:permissions)

    attributes.delete(:is_admin) unless ability.can?(:manage, :all)

    attributes[:permissions_attributes] = permissions_attributes(user, permissions) if ability.can?(:manage, :all) && !permissions.nil?

    # user_managers can only update is_active if the user is a non-admin
    attributes.delete(:is_active) unless ability.can?(:manage, user.admin? ? :all : user)

    # users cannot update their own email, only user_managers can
    attributes.delete(:email) unless ability.can?(:manage, User)

    success = update(user, attributes)

    raise(GraphQL::ExecutionError, user.errors.full_messages.join('; ')) unless success

    # Successful creation, return the created object with no errors
    { user: user }
  end

  private

    # Update password if attempting to do so otherwise ignore
    def update(user, attributes)
      changing_password?(attributes) ? user.update_with_password(attributes) : user.update_without_password(attributes)
    end

    def changing_password?(attributes)
      [:current_password, :password, :password_confirmation].any? { |k| attributes.include?(k) && attributes[k].present? }
    end

    def permissions_attributes(user, permissions)
      return nil if permissions.nil?

      new_permissions = permissions.uniq

      permission_attributes = user.permissions.where(subject: nil, subject_id: nil).map do |perm|
        if new_permissions.include?(perm.action)
          new_permissions.delete(perm.action)
          { id: perm.id, action: perm.action }
        else
          { id: perm.id, _destroy: true }
        end
      end

      permission_attributes.concat new_permissions.map { |new_perm| { action: new_perm } }

      permission_attributes
    end
end
