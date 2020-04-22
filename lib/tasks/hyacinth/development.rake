# frozen_string_literal: true

namespace :hyacinth do
  namespace :development do
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
      Rake::Task['hyacinth:setup:test_projects'].invoke
      Rake::Task['hyacinth:rights_fields:load'].invoke
      Rake::Task['hyacinth:setup:seed_dynamic_field_entries'].invoke
    end
  end
end
