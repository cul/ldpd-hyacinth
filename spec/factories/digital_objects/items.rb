# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: DigitalObject::Item do
    initialize_with do
      instance = new
      instance.primary_project = create(:project)
      instance
    end

    trait :with_descriptive_metadata do
      after(:build) do |digital_object|
        DynamicFieldsHelper.load_title_fields! # Adding dynamic fields used in descriptive metadata. Validations will fail if these field definitions aren't present.

        digital_object.assign_descriptive_metadata({
          'descriptive_metadata' => {
            'title' => [
              {
                'non_sort_portion' => 'The',
                'sort_portion' => 'Best Item Ever'
              }
            ]
          }
        })
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
        digital_object.append_child_uid(create(:asset, :with_master_resource, parent: digital_object).uid)
      end
    end
  end
end
