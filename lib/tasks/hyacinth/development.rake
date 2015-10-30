namespace :hyacinth do

  namespace :development do
    
    task :reset => :environment do
      
      unless Rails.env == 'development'
        puts 'This task is only meant for the development environment.'
        next
      end
      
      ENV['RAILS_ENV'] = Rails.env
      
      # Clear UriService data
      UriService.client.db[UriService::VOCABULARIES].delete
      UriService.client.db[UriService::TERMS].delete
      UriService.client.reindex_all_terms(true, false)
      # Setup UriService tables if they haven't already been set up
      Rake::Task["uri_service:db:setup"].invoke
      
      # Reset Hyacinth stuff
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:seed"].invoke
      ENV['CLEAR'] = 'true' # Set ENV variable for reindex task
      Rake::Task['hyacinth:index:reindex'].invoke
      ENV['CLEAR'] = nil  # Clear ENV variable because we're done with it
      Rake::Task['hyacinth:test:setup_test_project'].invoke
    end
    
  end

end
