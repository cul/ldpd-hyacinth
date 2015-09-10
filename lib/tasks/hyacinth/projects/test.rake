namespace :hyacinth do
  namespace :projects do

    # Test namespace for Test project tasks
    namespace :test do

      task :setup => :environment do

        # Load certain records that we'll be referencing
        dot_item = DigitalObjectType.find_by(string_key: 'item')
        dot_group = DigitalObjectType.find_by(string_key: 'group')
        dot_asset = DigitalObjectType.find_by(string_key: 'asset')



        # Create Test PID Generator
        test_pid_generator = PidGenerator.create!(namespace: 'test')

        # Create Test project
        test_project = Project.create!(string_key: 'test', display_label: 'Test', pid_generator: test_pid_generator)

        AuthorizedTerm.create!(
          value: 'Test Collection',
          controlled_vocabulary: ControlledVocabulary.find_by(string_key: 'collection')
        )

        # Create test DynamicFieldGroupCategory
        test_dynamic_field_group_category = DynamicFieldGroupCategory.create!(display_label: 'Test')

        # Create test DynamicFieldGroup and DynamicField

        test_dynamic_field = DynamicField.new(string_key: 'test_field', display_label: 'Test Field', dynamic_field_type: DynamicField::Type::STRING)
        test_dynamic_feld_group = DynamicFieldGroup.create!(string_key: 'test_field_group', display_label: 'Test Field Group', dynamic_field_group_category: test_dynamic_field_group_category,
          dynamic_fields: [
            test_dynamic_field
          ]
        )

        # Enable certain fields for various digital_object_types in test_project

        (DynamicFieldGroup.find_by(string_key: 'test_field_group').dynamic_fields + DynamicFieldGroup.find_by(string_key: 'title').dynamic_fields).each do |dynamic_field|
          test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_item)
          test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_asset)
          test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_group)
        end

        (DynamicFieldGroup.find_by(string_key: 'collection').dynamic_fields + DynamicFieldGroup.find_by(string_key: 'form').dynamic_fields).each do |dynamic_field|
          test_project.enabled_dynamic_fields << EnabledDynamicField.new(dynamic_field: dynamic_field, digital_object_type: dot_item)
        end

        # Let's create a test fieldset too
        fieldset1 = Fieldset.create!(display_label: 'Test Fieldset', project: test_project)

        # Add a subset of enabled dynamic fields to this fieldset
        test_project.enabled_dynamic_fields.each {|enabled_dynamic_field|
          if ['title_non_sort_portion', 'title_sort_portion'].include?(enabled_dynamic_field.dynamic_field.string_key)
            fieldset1.enabled_dynamic_fields << enabled_dynamic_field # This line acts instantly on the database. No additional save required.
          end
        }

        # TODO: Create Test PublishTarget

      end

    end
  end
end
