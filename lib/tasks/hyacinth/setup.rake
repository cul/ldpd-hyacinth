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
          User.create!(
            email: account_info[:email],
            uid: account_info[:uid],
            password: account_info[:password],
            password_confirmation: account_info[:password],
            first_name: account_info[:first_name],
            last_name: account_info[:last_name],
            is_admin: account_info[:is_admin]
          )
          puts Rainbow("Created user: #{user_email}").green
        end
      end
    end

    desc "Set up Test projects"
    task test_projects: :environment do
      [
        {
          string_key: 'test_primary_project',
          display_label: 'Test Primary Project',
          is_primary: true,
          has_asset_rights: true
        },
        {
          string_key: 'another_test_primary_project',
          display_label: 'Another Test Primary Project',
          is_primary: true,
          has_asset_rights: true
        },
        {
          string_key: 'test_aggregator_project',
          display_label: 'Test Aggregator Project',
          is_primary: false,
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
      user = User.find_by(email: default_user_accounts[0][:email])
      unless user
        puts Rainbow("seed_dynamic_field_entries requires default Admin user. Run default_users task first").red.bright
        next
      end

      df_category = DynamicFieldCategory.find_by(display_label: "Descriptive Metadata")
      if df_category
        puts Rainbow("dynamic field category 'Descriptive Metadata' already exists (skipping).").blue.bright
      else
        df_category = DynamicFieldCategory.create!(display_label: "Descriptive Metadata")
        puts Rainbow("Created dynamic field category 'Descriptive Metadata'").green
      end

      df_group = DynamicFieldGroup.find_by(string_key: "title")
      if df_group
        puts Rainbow("dynamic field group 'Title' already exists (skipping).").blue.bright
      else
        df_group = DynamicFieldGroup.create!(
          string_key: 'title',
          parent: df_category,
          display_label: 'Title',
          created_by: user,
          updated_by: user,
          parent_type: "DynamicFieldCategory"
        )
        puts Rainbow("Created dynamic field group 'Title'").green
      end

      default_dynamic_fields = [
        {
          display_label: 'Sort Portion',
          string_key: 'sort_portion',
          dynamic_field_group: df_group,
          field_type: 'string',
          created_by: user,
          updated_by: user,
          filter_label: '',
          controlled_vocabulary: '',
          select_options: '{}',
          additional_data_json: '{}'
        },
        {
          display_label: 'Non-Sort Portion',
          string_key: 'non_sort_portion',
          dynamic_field_group: df_group,
          field_type: 'string',
          created_by: user,
          updated_by: user,
          filter_label: '',
          controlled_vocabulary: '',
          select_options: '{}',
          additional_data_json: '{}'
        }
      ]

      default_dynamic_fields.each do |fields|
        if DynamicField.exists?(string_key: fields[:string_key])
          puts Rainbow("dynamic field #{fields[:display_label]} already exists (skipping).").blue.bright
        else
          DynamicField.create!(fields)
          puts Rainbow("Created dynamic field #{fields[:display_label]}").green
        end
      end
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
      }
    ]
  end
end
