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
      Rake::Task['hyacinth:setup:test_publish_targets'].invoke
      Rake::Task['hyacinth:rights_fields:load'].invoke
      Rake::Task['hyacinth:setup:seed_dynamic_field_entries'].invoke
      Rake::Task['hyacinth:setup:enable_fields_for_test_projects'].invoke
    end
    desc "Creates some sample records."
    task create_sample_records: :environment do
      unless Rails.env.development?
        puts 'This task can only be run in the development environment.'
        next
      end

      project = Project.create!(
        string_key: 'sample_record_project',
        display_label: 'Sample Record Project',
        has_asset_rights: true
      )

      # Enable title fields for the sample project
      project = Project.find_by(string_key: project.string_key)

      21.times do |i|
        item = DigitalObject::Item.new
        item.title = { 'value' => { 'sort_portion' => "Item #{i + 1}" } }
        item.primary_project = project

        next if item.save

        puts  "\nErrors encountered during item save.\n"\
              "Digital Object creation requirements may have changed since this rake task was last updated.\n"\
              "Errors:\n" +
              item.errors.full_messages.inspect
        break
      end
    end
  end

  desc 'Generate a new cop template'
  task :new_cop, [:cop] do |_task, args|
    require 'rubocop'

    cop_name = args.fetch(:cop) do
      warn 'usage: bundle exec rake new_cop[Department/Name]'
      exit!
    end

    github_user = `git config github.user`.chop
    github_user = 'your_id' if github_user.empty?
    generator = RuboCop::Cop::Generator.new(cop_name, github_user)

    generator.write_source
    generator.write_spec
    generator.inject_require(
      root_file_path: 'lib/rubocop/cop/hyacinth_cops.rb'
    )
    generator.inject_config(config_file_path: '.rubocop.yml')

    puts generator.todo
  end
end
