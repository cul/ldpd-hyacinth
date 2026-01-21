require 'base64'
require 'io/console'

namespace :hyacinth do
  namespace :users do
    # this is ported from the logic in users.js, with a longer default and b64 encoding
    def random_password(len = 24)
      chars = '01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
      result = ''
      (0...len).each { result << chars[rand(0...chars.length)] }
      Base64.strict_encode64(result)
    end

    desc "reset all user account credentials"
    task reset_all_creds: :environment do
      User.find_each do |user|
        user.update!(password: random_password)
      end
    end

    desc "reset a specific user credential to an input value"
    task reset_user_creds: :environment do
      user_id = ENV['id']&.to_i
      unless user_id
        puts "call this task with id=INTEGERID"
        abort
      end
      user = User.find(user_id)
      puts "Enter new password:"
      upw = STDIN.noecho(&:gets)
      upw.strip!
      user.update!(password: upw)
      puts "User<#{user_id}> '#{user.email}' assigned new #{upw.bytesize}-byte password"
    end

    desc "Create a new user with account_type 'service'"
    task create_service_account: :environment do
      required_params = ['uid', 'email', 'first_name', 'last_name', 'api_key']
      missing_required_params = required_params - ENV.keys
      if missing_required_params.present?
        abort("Missing required parameters: #{missing_required_params.join(', ')}")
      end
      user_params = ENV.slice(*required_params)
      puts "Creating user with params: #{user_params}"
      User.create!(user_params.merge({account_type: :service}))
    end

    desc "Create a new user with admin permission"
    task create_admin_user: :environment do
      required_params = ['uid', 'email', 'first_name', 'last_name']
      missing_required_params = required_params - ENV.keys
      if missing_required_params.present?
        abort("Missing required parameters: #{missing_required_params.join(', ')}")
      end
      user_params = ENV.slice(*required_params)
      puts "Creating user with params: #{user_params}"
      User.create!(user_params.merge({account_type: :standard}))
    end

    task list_user_permissions: :environment do
      puts '------------------------------'

      uid = ENV['uid']

      if uid.blank?
        puts "Please supply a uid"
        next
      end

      user = User.find_by(uid: uid)
      if user.blank?
        puts "Could not find a user with uid: #{uid}"
        next
      end

      puts "User: #{user.full_name} (#{user.uid})\n\n"

      if user.is_admin
        puts 'This user is an admin, so they have full access to all projects.'
      else
        project_permissions_for_projects_where_user_has_access = []
        projects_where_user_does_not_have_permissions = []
        Project.order(:display_label).each do |project|
          permissions = ProjectPermission.find_by(project: project, user: user)

          if permissions
            project_permissions_for_projects_where_user_has_access << permissions
          else
            projects_where_user_does_not_have_permissions << project
          end
        end

        if project_permissions_for_projects_where_user_has_access.present?
          puts 'Projects this user has access to:'
          project_permissions_for_projects_where_user_has_access.each do |project_permission|
            project = project_permission.project
            permission_string = 'read'
            permission_string += ', create' if project_permission.can_create
            permission_string += ', update' if project_permission.can_update
            permission_string += ', delete' if project_permission.can_delete
            permission_string += ', publish' if project_permission.can_publish
            permission_string += ', project admin' if project_permission.is_project_admin
            puts "- #{project.display_label} (#{project.string_key}): #{permission_string}"
          end
          puts ''
        end

        if projects_where_user_does_not_have_permissions.present?
          puts "Projects this user does NOT have access to:"
          projects_where_user_does_not_have_permissions.each do |project|
            puts "- #{project.display_label} (#{project.string_key})"
          end
        end
      end
    end

    # Fully replace to_user_uid user's permissions with from_user_uid user's permissions
    task copy_project_permissions: :environment do
      from_user_uid = ENV['from_user_uid']
      to_user_uid = ENV['to_user_uid']

      if from_user_uid.blank?
        puts "Please supply a from_user_uid"
        next
      end
      if to_user_uid.blank?
        puts "Please supply a to_user_uid"
        next
      end

      from_user = User.find_by(uid: from_user_uid)
      to_user = User.find_by(uid: to_user_uid)
      if from_user.blank?
        puts "Could not find user with uid: #{from_user_uid}"
        next
      end
      if to_user.blank?
        puts "Could not find user with uid: #{to_user_uid}"
        next
      end

      puts "\nReminder: This rake task only copies project permissions.  No other types of permissions are copied.\n\n"

      puts "Step 1: Deleting all project permissions currently assigned to user #{to_user.uid}..."
      ProjectPermission.where(user: to_user).destroy_all

      puts "Step 2: Copying all project permissions from user #{from_user.uid} to user #{to_user.uid}..."

      ProjectPermission.where(user: from_user).find_each do |project_permission|
        ProjectPermission.create!(
          user: to_user,
          project: project_permission.project,
          can_create: project_permission.can_create,
          can_update: project_permission.can_update,
          can_delete: project_permission.can_delete,
          can_publish: project_permission.can_publish,
          is_project_admin: project_permission.is_project_admin
        )
      end

      puts "Done!"
    end
  end
end
