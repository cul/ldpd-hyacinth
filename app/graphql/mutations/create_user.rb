class Mutations::CreateUser < Mutations::BaseMutation
  argument :first_name, String, required: true
  argument :last_name, String, required: true
  argument :email, String, required: true
  argument :password, String, required: true
  argument :password_confirmation, String, required: true
  argument :is_active, Boolean, required: false
  argument :is_admin, Boolean, required: false

  field :user, Types::UserType, null: true

  def resolve(**attributes)
    ability.authorize! :create, User

    user = User.new(
      first_name: attributes[:first_name],
      last_name: attributes[:last_name],
      email: attributes[:email],
      password: attributes[:password],
      password_confirmation: attributes[:password_confirmation]
    )

    user.is_active = is_active if attributes.key?(:is_active) && ability.can?(:manage, user)
    user.is_admin =  is_admin  if attributes.key?(:is_admin)  && ability.can?(:manage, :all)

    if user.save!
      {
        user: user
      }
    end
  end
end
