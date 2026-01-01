namespace :hyacinth do

  namespace :test do

    task :clear_local_default_resource_storage_content => :environment do
      unless Rails.env == 'test'
        puts 'This task is only meant for the test environment.'
        next
      end

      resource_types = [
        :main,
        :service,
        :access,
        :poster
      ]

      resource_types.each do |resource_type|
        location_uri = HYACINTH[:default_resource_storage_locations][resource_type][:file][:base]
        raise "Missing file storage configuration for: #{resource_type}" if location_uri.blank?
        directory = Hyacinth::Utils::UriUtils.location_uri_to_file_path(location_uri)
        puts "Deleting test HYACINTH[:default_resource_storage_locations][:#{resource_type}][:file][:base] files: #{directory}..."
        FileUtils.rm_rf(directory)
      end
      puts "Test environment default resource storage has been deleted."
    end

    task :setup_test_project => :environment do
      # Load certain records that we'll be referencing
      dot_item = DigitalObjectType.find_by(string_key: 'item')
      dot_group = DigitalObjectType.find_by(string_key: 'group')
      dot_asset = DigitalObjectType.find_by(string_key: 'asset')

      # Create Test PID Generator
      test_pid_generator = PidGenerator.create!(namespace: 'test')

      # Create Test project
      test_project = Project.create!(string_key: 'test', uri: 'id.library.columbia.edu/fake/test_project_uri', display_label: 'Test', pid_generator: test_pid_generator)

      # Create S3 Test project
      s3_test_project = Project.create!(
        string_key: 's3_test', uri: 'id.library.columbia.edu/fake/s3_test_project_uri', display_label: 'S3 Test', pid_generator: test_pid_generator,
        default_storage_type: Hyacinth::Storage::S3_SCHEME,
        default_access_storage_type: Hyacinth::Storage::FILE_SCHEME,
      )

      # Create test DynamicFieldGroupCategory
      test_dynamic_field_group_category = DynamicFieldGroupCategory.create!(display_label: 'Test')

      # Create test DynamicFieldGroup and DynamicField

      test_dynamic_feld_group = DynamicFieldGroup.create!(string_key: 'test_field_group', display_label: 'Test Field Group', dynamic_field_group_category: test_dynamic_field_group_category)
      test_dynamic_field = test_dynamic_feld_group.dynamic_fields.create!(string_key: 'test_field', display_label: 'Test Field', dynamic_field_type: DynamicField::Type::STRING)

      # Enable certain fields for various digital_object_types in test_project
      (DynamicFieldGroup.find_by(string_key: 'test_field_group').dynamic_fields + DynamicFieldGroup.find_by(string_key: 'title').dynamic_fields).each do |dynamic_field|
        test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_item)
        test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_asset)
        test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_group)

        s3_test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_item)
        s3_test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_asset)
        s3_test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_group)
      end

      (
       DynamicFieldGroup.find_by(string_key: 'collection').dynamic_fields +
       DynamicFieldGroup.find_by(string_key: 'form').dynamic_fields +
       DynamicFieldGroup.find_by(string_key: 'name').dynamic_fields +
       DynamicFieldGroup.find_by(string_key: 'name_role').dynamic_fields +
       DynamicFieldGroup.find_by(string_key: 'location').dynamic_fields
      ).each do |dynamic_field|
        test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_item)
        s3_test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_item)
      end

      # Let's create a test fieldset too
      fieldset1 = Fieldset.create!(display_label: 'Test Fieldset', project: test_project)

      # Add a subset of enabled dynamic fields to this fieldset
      test_project.enabled_dynamic_fields.each {|enabled_dynamic_field|
        if ['title_non_sort_portion', 'title_sort_portion'].include?(enabled_dynamic_field.dynamic_field.string_key)
          fieldset1.enabled_dynamic_fields << enabled_dynamic_field # This line acts instantly on the database. No additional save required.
        end
      }

      # Create Test Publish Targets
      test_publish_target_1 = DigitalObject::PublishTarget.new
      test_publish_target_1.set_digital_object_data(
        {
          'project' => { 'string_key' => 'publish_targets' },
          'publish_target_data' => {
            'string_key' => 'test_publish_target_1'
          },
          'dynamic_field_data' => {
            'title' => [
              'title_sort_portion' => 'Publish Target 1'
            ]
          }
        },
        false
      )
      test_publish_target_1.save

      test_publish_target_2 = DigitalObject::PublishTarget.new
      test_publish_target_2.set_digital_object_data(
        {
          'project' => { 'string_key' => 'publish_targets' },
          'publish_target_data' => {
            'string_key' => 'test_publish_target_2'
          },
          'dynamic_field_data' => {
            'title' => [
              'title_sort_portion' => 'Publish Target 2'
            ]
          }
        },
        false
      )
      test_publish_target_2.save

      # Enable test_publish_target_1 and test_publish_target_2 for test_project and s3_test_project
      test_project.enabled_publish_target_pids = [test_publish_target_1.pid, test_publish_target_2.pid]
      test_project.save
      s3_test_project.enabled_publish_target_pids = [test_publish_target_1.pid, test_publish_target_2.pid]
      s3_test_project.save
    end

  end

end
