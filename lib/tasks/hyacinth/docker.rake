# frozen_string_literal: true

namespace :hyacinth do
  namespace :docker do
    def docker_compose_file_path
      Rails.root.join("docker/docker-compose.#{Rails.env}.yml")
    end

    def docker_compose_config
      YAML.load_file(docker_compose_file_path)
    end

    def running?
      status = `docker compose -f #{Rails.root.join(docker_compose_file_path)} ps`
      status.split("n").count > 1
    end

    task start: :environment do
      puts "Starting...\n"
      if running?
        puts "\nAlready running."
      else
        `docker compose -f #{docker_compose_file_path} up --build --detach`
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
