namespace :hyacinth do
  namespace :setup do
    desc "Set up hyacinth config files"
    task :config_files do # rubocop:disable Rails/RakeEnvironment
      config_template_dir = Rails.root.join('config', 'templates')
      config_dir = Rails.root.join('config')
      Dir.foreach(config_template_dir) do |entry|
        next unless entry.end_with?('.yml')
        src_path = File.join(config_template_dir, entry)
        dst_path = File.join(config_dir, entry.gsub('.template', ''))
        if File.exist?(dst_path)
          puts Rainbow("File already exists (skipping): #{dst_path}").blue.bright + "\n"
        else
          FileUtils.cp(src_path, dst_path)
          puts Rainbow("Created file at: #{dst_path}").green
        end
      end

      # And create secrets.yml if it doesn't exist
      puts 'Checking for secrets.yml file...'
      secrets_yml_file_path = File.join(Rails.root, 'config/secrets.yml')
      if File.exist?(secrets_yml_file_path)
        puts Rainbow("File already exists (skipping): #{secrets_yml_file_path}").blue.bright + "\n"
      else
        File.open(secrets_yml_file_path, 'w') {|f| f.write generate_new_secrets_yml_content.to_yaml }
        puts Rainbow("Created file at: #{secrets_yml_file_path}").green
      end
    end

    def generate_new_secrets_yml_content
      secrets_yml_content = {}
      ['development', 'test'].each do |env_name|
        secrets_yml_content[env_name] = {
          'secret_key_base' => SecureRandom.hex(64),
          'session_store_key' =>  '_hyacinth_' + env_name + '_session_key'
        }
      end
      secrets_yml_content
    end
  end
end
