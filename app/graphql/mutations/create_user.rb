class Mutations::CreateUser < Mutations::BaseMutation
  argument :first_name, String, required: true
  argument :last_name, String, required: true
  argument :email, String, required: true
  argument :password, String, required: true
  argument :password_confirmation, String, required: true
  argument :is_active, Boolean, required: false
  argument :is_admin, Boolean, required: false

  field :user, Types::UserType, null: true

  def resolve(first_name:, last_name:, email:, password:, password_confirmation:, is_active: false, is_admin: false)
    context[:ability].authorize! :create, User

    user = User.new(
      first_name: first_name,
      last_name: last_name,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )

    user.is_active = is_active if context[:ability].can?(:manage, user)
    user.is_admin = is_admin if context[:ability].can?(:manage, :all)

    if user.save!
      # Successful creation, return the created object with no errors
      {
        user: user
      }
    end
  end
end
