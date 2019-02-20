namespace :hyacinth do
  namespace :setup do
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

    desc 'Set up default accounts'
    task default_accounts: :environment  do
      default_user_accounts = [
        {
          email: 'hyacinth-admin@library.columbia.edu',
          password: 'iamtheadmin',
          first_name: 'Admin',
          last_name: 'User'
        },
        {
          email: 'hyacinth-test@library.columbia.edu',
          password: 'iamthetest',
          first_name: 'Test',
          last_name: 'User'
        }
      ]

      default_user_accounts.each do |account|
        User.create!(
          email: account[:email],
          password: account[:password],
          password_confirmation: account[:password],
          first_name: account[:first_name],
          last_name: account[:last_name]
        )
      end
    end
  end
end
