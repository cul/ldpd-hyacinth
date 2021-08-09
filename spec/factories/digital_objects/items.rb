# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: DigitalObject::Item do
    after(:build) do |digital_object|
      digital_object.primary_project = create(:project) if digital_object.primary_project.blank?
    end

    # Timestamps are set when an object is saved, but sometimes it's useful
    # to have timestamps set when we build an object and haven't saved it yet.
    trait :with_timestamps do
      created_at { DateTime.current }
      updated_at { DateTime.current }
    end

    trait :with_ascii_title do
      after(:build) do |digital_object|
        dynamic_fields = DynamicFieldsHelper.load_title_fields! # Adding dynamic fields used in descriptive metadata. Validations will fail if these field definitions aren't present.
        DynamicFieldsHelper.enable_dynamic_fields(digital_object.digital_object_type, digital_object.primary_project, dynamic_fields)
        digital_object.assign_descriptive_metadata(
          'descriptive_metadata' => {
            'title' => [
              {
                'non_sort_portion' => 'The',
                'sort_portion' => 'Best Item Ever'
              }
            ]
          }
        )
      end
    end

    trait :with_utf8_title do
      after(:build) do |digital_object|
        dynamic_fields = DynamicFieldsHelper.load_title_fields! # Adding dynamic fields used in descriptive metadata. Validations will fail if these field definitions aren't present.
        DynamicFieldsHelper.enable_dynamic_fields(digital_object.digital_object_type, digital_object.primary_project, dynamic_fields)
        digital_object.assign_descriptive_metadata(
          'descriptive_metadata' => {
            'title' => [
              {
                'sort_portion' => [80, 97, 114, 97, 32, 77, 97, 99, 104, 117, 99, 97, 114, 32, 77, 101, 117, 32, 67, 111, 114, 97, 231, 227, 111].pack("U*")
              }
            ]
          }
        )
      end
    end

    trait :with_rights do
      after(:build) do |digital_object|
        Hyacinth::DynamicFieldsLoader.load_rights_fields!(load_vocabularies: true)

        digital_object.assign_rights({
          'rights' => {
            'descriptive_metadata' => [
              { 'type_of_content' => 'literary' }
            ]
          }
        }, false)
      end
    end

    trait :with_primary_project_asset_rights do
      after(:build) do |digital_object|
        digital_object.primary_project = create(:project, :allow_asset_rights)
      end
    end

    trait :with_other_projects do
      after(:build) do |digital_object|
        ['a', 'b'].each do |val|
          digital_object.other_projects << create(
            :project,
            string_key: "other_project_#{val}",
            display_label: "Other Project #{val.upcase}",
            project_url: "https://example.com/other_project_#{val}"
          )
        end
      end
    end

    trait :with_asset do
      after(:create) do |digital_object|
        digital_object.children_to_add << create(:asset, :with_main_resource)
        digital_object.save
      end
    end
  end
end
