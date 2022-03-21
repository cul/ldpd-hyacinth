# frozen_string_literal: true

# This mutation can be used by admins to switch to a different user account
# (for troubleshooting an issue as that user).
class Mutations::SwitchToUser < Mutations::BaseMutation
  argument :id, ID, required: true

  field :success, Boolean, null: true

  def resolve(id:)
    # Only allow admins to use this mutation
    ability.authorize! :manage, :all

    context[:sign_in_lambda].call(
      User.find_by!(uid: id)
    )

    # If we got here, user-switching was successful
    { success: true }
  end
end
