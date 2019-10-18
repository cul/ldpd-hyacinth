class Mutations::CreateUser < Mutations::BaseMutation
  argument :first_name, String, required: true
  argument :last_name, String, required: true
  argument :email, String, required: true
  argument :password, String, required: true
  argument :password_confirmation, String, required: true

  field :user, Types::UserType, null: true

  # We don't support all user parameters at this point at creation time. We might want to rethink this in the future.
  # In order to support the rest of the parameters we need a pattern to follow when sharing code between mutations.

  def resolve(**attributes)
    ability.authorize! :create, User

    user = User.new(
      first_name: attributes[:first_name],
      last_name: attributes[:last_name],
      email: attributes[:email],
      password: attributes[:password],
      password_confirmation: attributes[:password_confirmation]
    )

    { user: user } if user.save!
  end
end
