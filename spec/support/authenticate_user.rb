# frozen_string_literal: true

module AuthenticateUser
  def sign_in_user(as: [])
    user = FactoryBot.create(
      :user,
      *Array.wrap(as),
      first_name: 'Signed In',
      last_name: 'User',
      email: 'logged-in-user@exaple.com'
    )

    login_as user, scope: :user
  end

  def sign_in_project_contributor(**args)
    user = create_project_contributor(args)

    login_as user, scope: :user
  end

  def create_project_contributor(to:, project:)
    permissions = Array.wrap(to).map { |action| Permission.new(action: action, subject: Project.to_s, subject_id: project.id) }

    FactoryBot.create(
      :user, first_name: 'Signed In', last_name: 'User', email: 'logged-in-user@exaple.com', permissions: permissions
    )
  end
end
