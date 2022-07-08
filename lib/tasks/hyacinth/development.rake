# frozen_string_literal: true

namespace :hyacinth do
  namespace :development do

    namespace :docker do
      def docker_compose_file_path
        Rails.root.join("docker/docker-compose.#{Rails.env}.yml")
      end

      def docker_compose_config
        YAML.load_file(docker_compose_file_path)
      end

      def is_running
        status = `docker compose -f #{Rails.root.join(docker_compose_file_path)} ps`
        return status.split("n").count > 1
      end

      task start: :environment do
        puts "Starting...\n"
        if is_running
          puts "\nAlready running."
        else
          `docker compose -f #{docker_compose_file_path} up --build --detach`
          puts "\nStarted."
        end
      end

      task stop: :environment do
        puts "Stopping...\n"
        if is_running
          puts "\n"
          `docker compose -f #{Rails.root.join(docker_compose_file_path)} down`
          puts "\nStopped"
        else
          puts "Already stopped."
        end
      end

      task status: :environment do
        puts is_running ? 'Running.' : 'Not running.'
      end

      task clear_volumes: :environment do
        puts Rainbow("This will delete ALL Solr, Redis, and Fedora data for the selected Rails environment (#{Rails.env}) and cannot be undone. "\
          "Please confirm that you want to continue by typing in the selected Rails environment (#{Rails.env}):").red.bright
        print '> '
        response = ENV['rails_env_confirmation'] || $stdin.gets.chomp
        config = docker_compose_config
        volume_prefix = config['name']
        full_volume_names = config['volumes'].keys.map { |short_name| "#{volume_prefix}_#{short_name}"}

        puts "Deleting #{full_volume_names.join(', ')} ..."
      end
    end

    desc "Resets the development environment, clearing all data and setting up default objects."
    task reset: :environment do
      unless Rails.env.development?
        puts 'This task can only be run in the development environment.'
        next
      end

      begin
        Hyacinth::Config.digital_object_search_adapter.search({})
      rescue Errno::ECONNREFUSED
        # Solr isn't running so we'll start it
        Rake::Task['solr:start'].invoke
      end

      ENV['rails_env_confirmation'] = 'development' # allow automatic prompt confirmation in purge task
      Rake::Task['hyacinth:purge_all_digital_objects'].invoke
      ENV.delete('yes') # done with this env variable

      Rake::Task['db:environment:set'].invoke
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke

      Rake::Task['hyacinth:setup:config_files'].invoke
      Rake::Task['hyacinth:setup:default_users'].invoke
      Rake::Task['hyacinth:rights_fields:load'].invoke
    end
  end
end
