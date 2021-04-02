# frozen_string_literal: true

namespace :hyacinth do
  namespace :setup do
    desc "Set up hyacinth config files"
    task :config_files do
      config_template_dir = Rails.root.join('config', 'templates')
      config_dir = Rails.root.join('config')
      Dir.foreach(config_template_dir) do |entry|
        next unless entry.end_with?('.yml')
        src_path = File.join(config_template_dir, entry)
        dst_path = File.join(config_dir, entry.gsub('.template', ''))
        if File.exist?(dst_path)
          puts Rainbow("File already exists (skipping): #{dst_path}").blue.bright + "\n"
        else
          FileUtils.cp(src_path, dst_path)
          puts Rainbow("Created file at: #{dst_path}").green
        end
      end
    end

    desc "Set up default Hyacinth users"
    task default_users: :environment do
      default_user_accounts.each do |account_info|
        user_email = account_info[:email]

        if User.exists?(email: user_email)
          puts Rainbow("Skipping creation of user #{user_email} because user already exists.").blue.bright
        else
          User.create!(account_info.merge(password_confirmation: account_info[:password]))
          puts Rainbow("Created user: #{user_email}").green
        end
      end
    end

    desc "Set up Test projects"
    task test_projects: :environment do
      [
        {
          string_key: 'test_project',
          display_label: 'Test Project',
          has_asset_rights: true
        },
        {
          string_key: 'project_a',
          display_label: 'Project A',
          has_asset_rights: true
        },
        {
          string_key: 'project_b',
          display_label: 'Project B',
          has_asset_rights: false
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

    desc "Add Descriptive Metadata category and Title dynamic fields"
    task seed_dynamic_field_entries: :environment do
      field_definitions = {
        dynamic_field_categories: [{
          display_label: "Descriptive Metadata",
          dynamic_field_groups: [
            {
              string_key: 'title',
              display_label: 'Title',
              dynamic_fields: [
                { display_label: 'Non-Sort Portion', sort_order: 1, string_key: 'non_sort_portion', field_type: DynamicField::Type::STRING },
                { display_label: 'Sort Portion', sort_order: 2, string_key: 'sort_portion', field_type: DynamicField::Type::STRING }
              ]
            }
          ]
        }]
      }

      Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions)
    end

    desc "Enables some basic fields for the test projects"
    task enable_fields_for_test_projects: :environment do
      title_subfields = DynamicFieldGroup.find_by(string_key: "title").dynamic_fields
      projects = Project.where(string_key: ['test_primary_project', 'another_test_primary_project'])
      projects.each do |project|
        title_subfields.each do |title_subfield|
          EnabledDynamicField.create!(
            project: project,
            dynamic_field: title_subfield,
            digital_object_type: 'item'
          )
        end
      end
    end
  end

  def default_user_accounts
    [
      {
        email: 'hyacinth-admin@library.columbia.edu',
        password: 'iamtheadmin',
        first_name: 'Admin',
        last_name: 'User',
        uid: SecureRandom.uuid,
        is_admin: true
      },
      {
        email: 'hyacinth-test@library.columbia.edu',
        password: 'iamthetest',
        first_name: 'Test',
        last_name: 'User',
        uid: SecureRandom.uuid,
        is_admin: false
      },
      {
        email: 'derivativo@library.columbia.edu',
        password: 'derivativo',
        first_name: 'Derivativo',
        last_name: 'Service',
        uid: SecureRandom.uuid,
        is_admin: false,
        permissions_attributes: [
          {
            subject: nil,
            subject_id: nil,
            action: Permission::MANAGE_ALL_DIGITAL_OBJECTS
          },
          {
            subject: nil,
            subject_id: nil,
            action: Permission::MANAGE_RESOURCE_REQUESTS
          }
        ]
      }
    ]
  end
end
