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
  end
end
