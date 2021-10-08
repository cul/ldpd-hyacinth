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

  def create_project_contributor(actions:, projects:)
    permissions = Array.wrap(actions).product(Array.wrap(projects)).map do |action, project|
      Permission.new(action: action, subject: Project.to_s, subject_id: project.id)
    end

    FactoryBot.create(
      :user, first_name: 'Signed In', last_name: 'User', email: 'logged-in-user@exaple.com', permissions: permissions
    )
  end

  def sign_in_user_manager(**args)
    user = create_user_manager(**args)

    login_as user, scope: :user
  end

  def create_user_manager(**_args)
    permissions = [Permission.create(action: Permission::MANAGE_USERS)]

    FactoryBot.create(
      :user, first_name: 'Signed In', last_name: 'User', email: 'logged-in-user@exaple.com', permissions: permissions
    )
  end
end
