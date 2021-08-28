# frozen_string_literal: true

FactoryBot.define do
  class DigitalObject::TestSubclass < DigitalObject
    metadata_attribute :custom_field1, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'custom default value 1' }).private_writer
    metadata_attribute :custom_field2, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'custom default value 2' })
    resource_attribute :test_resource1
    resource_attribute :test_resource2
  end

  # Add ability to resolve digital object type to class
  Hyacinth::Config.digital_object_types.register('test_subclass', DigitalObject::TestSubclass)

  factory :digital_object_test_subclass, class: DigitalObject::TestSubclass do
    after(:build) do |digital_object|
      digital_object.primary_project = create(:project)
    end

    before(:create) do |digital_object|
      DynamicFieldsHelper.enable_dynamic_fields(digital_object.digital_object_type, digital_object.primary_project)
    end

    trait :with_sample_data do
      with_ascii_title
      with_ascii_dynamic_field_data

      after(:build) do |digital_object|
        digital_object.instance_variable_set('@custom_field1', 'excellent value 1')
        digital_object.instance_variable_set('@custom_field2', 'excellent value 2')
      end
    end

    trait :with_ascii_title do
      after(:build) do |digital_object|
        digital_object.title = {
          'non_sort_portion' => 'The',
          'sort_portion' => 'Tall Man and His Hat'
        }
      end
    end

    trait :with_ascii_dynamic_field_data do
      after(:build) do |digital_object|
        dynamic_fields = DynamicFieldsHelper.load_alternate_title_fields! # Adding dynamic fields used in descriptive metadata. Validations will fail if these field definitions aren't present.
        DynamicFieldsHelper.enable_dynamic_fields(digital_object.digital_object_type, digital_object.primary_project, dynamic_fields)
        digital_object.assign_descriptive_metadata(
          'descriptive_metadata' => {
            'alternate_title' => [
              {
                'value' => 'Other Title'
              }
            ]
          }
        )
      end
    end

    trait :with_test_resource1 do
      after(:build) do |digital_object|
        test_file_fixture_path = Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s

        digital_object.resources['test_resource1'] = Hyacinth::DigitalObject::Resource.new(
          location: 'tracked-disk://' + test_file_fixture_path,
          checksum: 'sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2',
          original_file_path: test_file_fixture_path,
          media_type: 'text/plain',
          file_size: File.size(test_file_fixture_path)
        )
      end
    end

    trait :with_lincoln_project do
      after(:build) do |digital_object|
        digital_object.primary_project = create(:project, :legend_of_lincoln)
      end
    end

    trait :with_minken_project do
      after(:build) do |digital_object|
        digital_object.primary_project = create(:project, :myth_of_minken)
      end
    end
  end
end
