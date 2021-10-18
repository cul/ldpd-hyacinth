# frozen_string_literal: true

namespace :hyacinth do
  namespace :sample_content do
    desc "Creates sample content (projects, publish targets, fields, sample record)"
    task create: :environment do
      Rake::Task['hyacinth:sample_content:create_projects'].invoke
      Rake::Task['hyacinth:sample_content:create_publish_targets'].invoke
      Rake::Task['hyacinth:sample_content:create_and_enable_fields'].invoke
      Rake::Task['hyacinth:sample_content:create_records'].invoke
    end

    task create_projects: :environment do
      [
        {
          string_key: 'sample_project',
          display_label: 'Sample Project',
          has_asset_rights: true
        },
        {
          string_key: 'other_sample_project',
          display_label: 'Other Sample Project',
          has_asset_rights: true
        }
      ].each do |project_config|
        project_string_key = project_config[:string_key]
        if Project.exists?(string_key: project_string_key)
          puts Rainbow("Skipping creation of project #{project_string_key} because project already exists.").blue.bright
        else
          Project.create!(project_config)
          puts Rainbow("Created project: #{project_string_key}").green
        end
      end
    end

    task create_publish_targets: :environment do
      [
        {
          string_key: 'sample_publish_target',
          publish_url: 'https://www.example.com/publish',
          api_key: 'sample_api_key',
          is_allowed_doi_target: true
        }
      ].each do |publish_target_config|
        publish_target_string_key = publish_target_config[:string_key]
        if PublishTarget.exists?(string_key: publish_target_string_key)
          puts Rainbow("Skipping creation of publish target #{publish_target_string_key} because publish target already exists.").blue.bright
        else
          PublishTarget.create!(publish_target_config)
          puts Rainbow("Created publish target: #{publish_target_string_key}").green
        end
      end
    end

    task create_and_enable_fields: :environment do
      Hyacinth::DynamicFieldsLoader.load_fields!(
        dynamic_field_categories: [{
          display_label: "Sample Field Category",
          metadata_form: 'descriptive',
          dynamic_field_groups: [
            {
              string_key: 'sample_field_group',
              display_label: 'Sample Field Group',
              dynamic_fields: [
                { display_label: 'Sample Field', sort_order: 1, string_key: 'sample_field', field_type: DynamicField::Type::STRING }
              ]
            },
            {
              string_key: 'other_sample_field_group',
              display_label: 'Other Sample Field Group',
              dynamic_fields: [
                { display_label: 'Other Sample Field', sort_order: 1, string_key: 'other_sample_field', field_type: DynamicField::Type::STRING }
              ]
            }
          ]
        }]
      )

      sample_project.tap do |project|
        fields = [
          DynamicField.find_by_path_traversal(['sample_field_group', 'sample_field']),
          DynamicField.find_by_path_traversal(['other_sample_field_group', 'other_sample_field'])
        ]

        fields.each do |field|
          Hyacinth::Config.digital_object_types.keys.each do |digital_object_type|
            EnabledDynamicField.create!(
              project: project,
              dynamic_field: field,
              digital_object_type: digital_object_type
            )
          end
        end
      end
    end

    task create_records: :environment do
      sample_project.tap do |project|
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

    def sample_project
      Project.find_by(string_key: 'sample_project')
    end
  end
end
