# frozen_string_literal: true

class Mutations::ImpersonateUser < Mutations::BaseMutation
  argument :id, ID, required: true

  field :success, Boolean, null: false

  def resolve(id:)
    user = User.find_by!(uid: id)

    # Only admins can impersonate users.
    ability.authorize! :manage, :all

    # Sign in as the requested user
    context[:sign_in_lambda].call(user)

    { success: true }
  end
end
