namespace :hyacinth do
  namespace :projects do
    namespace :varsity_show do
      
      task :setup => :environment do
        # Create Varsity Show project
        varsity_show_project = Project.create!(string_key: 'varsity_show', display_label: 'Varsity Show', pid_generator: PidGenerator.default_pid_generator)
        
        # Create fields:
        # omeka_identifier -> omeka_identifier_value
        # language -> language_term
        # location -> location_url_object_in_context
      end
      
    end
  end
end