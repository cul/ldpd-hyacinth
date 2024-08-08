# frozen_string_literal: true

namespace :hyacinth do
  namespace :docker do
    def docker_compose_file_path
      Rails.root.join("docker/docker-compose.#{Rails.env}.yml")
    end

    def docker_compose_config
      YAML.load_file(docker_compose_file_path)
    end

    def wait_for_solr_cores_to_load
      expected_port = docker_compose_config['services']['solr']['ports'][0].split(':')[0]
      url_to_check = "http://localhost:#{expected_port}/solr/hyacinth/admin/system"
      puts "Waiting for Solr to become available (at #{url_to_check})..."
      Timeout.timeout(20, Timeout::Error, 'Timed out during Solr startup check.') do
        loop do
          begin
            sleep 0.25
            status_code = Net::HTTP.get_response(URI(url_to_check)).code
            if status_code == '200' # Solr is ready to receive requests
              puts 'Solr is available.'
              break
            end
          rescue EOFError, Errno::ECONNRESET => e
            # Try again in response to the above error types
            next
          end
        end
      end
    end

    def wait_for_fedora_to_load
      expected_port = docker_compose_config['services']['fedora']['ports'][0].split(':')[0]
      url_to_check = "http://localhost:#{expected_port}/fedora/describe"
      puts "Waiting for Fedora to become available (at #{url_to_check})..."
      Timeout.timeout(20, Timeout::Error, 'Timed out during Fedora startup check.') do
        loop do
          begin
            sleep 0.25
            status_code = Net::HTTP.get_response(URI(url_to_check)).code
            if status_code == '401' # Fedora is ready and prompting for authentication
              puts 'Fedora is available.'
              break
            end
          rescue EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED => e
            # Try again in response to the above error types
            next
          end
        end
      end
    end

    def running?
      status = `docker compose -f #{Rails.root.join(docker_compose_file_path)} ps`
      status.split("n").count > 1
    end

    task setup_config_files: :environment do
      docker_compose_template_dir = Rails.root.join('docker/templates')
      docker_compose_dest_dir = Rails.root.join('docker')
      Dir.foreach(docker_compose_template_dir) do |entry|
        next unless entry.end_with?('.yml') || entry.end_with?('.env')
        src_path = File.join(docker_compose_template_dir, entry)
        dst_path = File.join(docker_compose_dest_dir, entry.gsub('.template', ''))
        if File.exist?(dst_path)
          puts Rainbow("File already exists (skipping): #{dst_path}").blue.bright + "\n"
        else
          FileUtils.cp(src_path, dst_path)
          puts Rainbow("Created file at: #{dst_path}").green
        end
      end
    end

    task start: :environment do
      puts "Starting...\n"
      if running?
        puts "\nAlready running."
      else
        # NOTE: This command rebuilds the container images before each run, to ensure they're
        # always up to date. In most cases, the overhead is minimal if the Dockerfile for an image
        # hasn't changed since the last build.
        `docker compose -f #{docker_compose_file_path} up --build --detach --wait`
        wait_for_solr_cores_to_load
        wait_for_fedora_to_load
        puts "\nStarted."
      end
    end

    task stop: :environment do
      puts "Stopping...\n"
      if running?
        puts "\n"
        `docker compose -f #{Rails.root.join(docker_compose_file_path)} down`
        puts "\nStopped"
      else
        puts "Already stopped."
      end
    end

    task restart: :environment do
      Rake::Task['hyacinth:docker:stop'].invoke
      Rake::Task['hyacinth:docker:start'].invoke
    end

    task status: :environment do
      puts running? ? 'Running.' : 'Not running.'
    end

    task delete_volumes: :environment do
      if running?
        puts 'Error: The volumes are currently in use. Please stop the docker services before deleting the volumes.'
        next
      end

      puts Rainbow("This will delete ALL Solr, Redis, and Fedora data for the selected Rails "\
        "environment (#{Rails.env}) and cannot be undone. Please confirm that you want to continue "\
        "by typing the name of the selected Rails environment (#{Rails.env}):").red.bright
      print '> '
      response = ENV['rails_env_confirmation'] || $stdin.gets.chomp

      puts ""

      if response != Rails.env
        puts "Aborting because \"#{Rails.env}\" was not entered."
        next
      end

      config = docker_compose_config
      volume_prefix = config['name']
      full_volume_names = config['volumes'].keys.map { |short_name| "#{volume_prefix}_#{short_name}" }

      full_volume_names.map do |full_volume_name|
        if JSON.parse(Open3.capture3("docker volume inspect '#{full_volume_name}'")[0]).length.positive?
          `docker volume rm '#{full_volume_name}'`
          puts Rainbow("Deleted: #{full_volume_name}").green
        else
          puts Rainbow("Skipped: #{full_volume_name} (already deleted)").blue.bright
        end
      end

      puts 'Done.'
    end
  end
end
