# frozen_string_literal: true

namespace :hyacinth do
  namespace :setup do
    desc "Set up default Hyacinth users"
    task default_users: :environment do
      default_user_accounts.each do |account_info|
        user_email = account_info[:email]
        if User.exists?(email: account_info[:email])
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

    desc "Add minimal required dynamic fields for digital object creation"
    task seed_dynamic_field_entries: :environment do
      user = User.find_by(email: default_user_accounts[0][:email]);
      if !user
        puts Rainbow("seed_dynamic_field_entries requires default Admin user. Run default_users task first").red.bright
        next
      end
      df_category = DynamicFieldCategory.find_by(display_label: "Descriptive Metadata")
      df_group = DynamicFieldGroup.find_by(display_label: "Title")

      if df_category
        puts Rainbow("dynamic field category 'Descriptive Metadata' already exists (skipping).").blue.bright
      else
        df_category = DynamicFieldCategory.create!(display_label: "Descriptive Metadata")
        puts Rainbow("Created dynamic field category 'Descriptive Metadata'").green
      end

      if df_group
        puts Rainbow("dynamic field group 'Title' already exists (skipping).").blue.bright
      else
        df_group = DynamicFieldGroup.create!(
          string_key: 'title',
          parent: df_category,
          display_label: 'Title',
          created_by: user,
          updated_by: user,
          parent_type: "DynamicFieldCategory",
        )
        puts Rainbow("Created dynamic field group 'Title'").green
      end


      default_dynamic_fields = [
        {
          display_label: 'Sort Portion',
          string_key: 'title_sort_portion',
          dynamic_field_group: df_group,
          field_type: 'string',
          created_by: user,
          updated_by: user,
        },
        {
          display_label: 'Non-Sort Portion',
          string_key: 'title_non_sort_portion',
          dynamic_field_group: df_group,
          field_type: 'string',
          created_by: user,
          updated_by: user,
        }
      ]

      default_dynamic_fields.each do |field|
        if DynamicField.exists?(string_key: field[:string_key])
          puts Rainbow("dynamic field #{field[:display_label]} already exists (skipping).").blue.bright
        else
          DynamicField.create!(
            display_label: field[:display_label],
            string_key: field[:string_key],
            dynamic_field_group: field[:dynamic_field_group],
            field_type: field[:field_type],
            created_by: field[:created_by],
            updated_by: field[:updated_by]
          )
          puts Rainbow("Created dynamic field #{field[:display_label]}").green
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
        is_admin: true
      }
    ]
  end

end
