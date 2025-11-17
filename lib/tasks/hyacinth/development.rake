namespace :hyacinth do

  namespace :development do

    task :reset => :environment do

      unless Rails.env == 'development'
        puts 'This task is only meant for the development environment.'
        next
      end

      ENV['RAILS_ENV'] = Rails.env

      # Clear UriService data and set up required tables
      Rake::Task["uri_service:db:drop_tables_and_clear_solr"].invoke
      Rake::Task["uri_service:db:setup"].invoke

      # Reset Hyacinth stuff
      Rake::Task['db:environment:set'].invoke
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke

      Rake::Task["hyacinth:setup:core_records"].invoke
      Rake::Task["hyacinth:setup:default_users"].invoke
      ENV['CLEAR'] = 'true' # Set ENV variable for reindex task
      Rake::Task['hyacinth:index:reindex'].invoke
      ENV['CLEAR'] = nil  # Clear ENV variable because we're done with it
      Rake::Task['hyacinth:test:setup_test_project'].invoke
    end

  end

end
