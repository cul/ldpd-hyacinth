namespace :hyacinth do
  namespace :setup do
    desc "Set up default Hyacinth users and groups"
    task default_users_and_groups: :environment do
      default_user_accounts = [
        {
          email: 'hyacinth-admin@library.columbia.edu',
          password: 'iamtheadmin',
          first_name: 'Admin',
          last_name: 'User',
          uid: SecureRandom.uuid
        },
        {
          email: 'hyacinth-test@library.columbia.edu',
          password: 'iamthetest',
          first_name: 'Test',
          last_name: 'User',
          uid: SecureRandom.uuid
        }
      ]

      default_user_accounts.each do |account_info|
        user_email = account_info[:email]
        if User.exists?(email: account_info[:email])
          puts Rainbow("Skipping creation of user #{user_email} because user already exists.").blue.bright
        else
          User.create!(
            email: account_info[:email],
            uid: account_info[:uid],
            password: account_info[:password],
            password_confirmation: account_info[:password],
            first_name: account_info[:first_name],
            last_name: account_info[:last_name]
          )
          puts Rainbow("Created user: #{user_email}").green
        end
      end

      default_groups = [
        {
          string_key: 'administrators',
          is_admin: true,
          users: [User.find_by(email: 'hyacinth-admin@library.columbia.edu')]
        }
      ]

      default_groups.each do |group_info|
        if Group.exists?(string_key: group_info[:string_key])
          puts Rainbow("Skipping creation of group #{group_info[:string_key]} because user already exists.").blue.bright
        else
          Group.create!(
            string_key: group_info[:string_key],
            is_admin: group_info[:is_admin],
            users: group_info[:users]
          )
          puts Rainbow("Created group: #{group_info[:string_key]}").green
        end
      end
    end

    desc "Set up hyacinth config files"
    task :config_files do
      config_template_dir = Rails.root.join('config/templates')
      config_dir = Rails.root.join('config')
      Dir.foreach(config_template_dir) do |entry|
        next unless entry.end_with?('.yml')
        src_path = File.join(config_template_dir, entry)
        dst_path = File.join(config_dir, entry.gsub('.template', ''))
        if File.exist?(dst_path)
          puts Rainbow("Existing file found at: #{dst_path}").blue.bright + "\n" +
            Rainbow("  Skipping copy. Delete file and re-run this task if you want to replace it.").yellow
        else
          FileUtils.cp(src_path, dst_path)
          puts Rainbow("Created file at: #{dst_path}").green
        end
      end
    end
  end
end
