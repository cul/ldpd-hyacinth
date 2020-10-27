# frozen_string_literal: true

FactoryBot.define do
  factory :asset, class: DigitalObject::Asset do
    parent { nil } # parent should be passed in when factory build or create or called, otherwise this object won't validate
    asset_type { nil }
    initialize_with do
      instance = new
      if parent
        instance.primary_project = parent.primary_project
        instance.add_parent_uid(parent.uid)
      else
        instance.primary_project = create(:project)
      end
      instance.asset_type = asset_type
      instance
    end

    trait :with_descriptive_metadata do
      after(:build) do |digital_object|
        DynamicFieldsHelper.load_title_fields! # Load fields

        digital_object.assign_descriptive_metadata(
          'descriptive_metadata' => {
            'title' => [
              {
                'non_sort_portion' => 'The',
                'sort_portion' => 'Best Asset Ever'
              }
            ]
          }
        )
      end
    end

    trait :with_master_resource do
      after(:build) do |digital_object|
        test_file_fixture_path = Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s

        digital_object.resources['master'] = Hyacinth::DigitalObject::Resource.new(
          location: 'managed-disk://' + test_file_fixture_path,
          checksum: 'sha256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6',
          original_file_path: test_file_fixture_path,
          media_type: 'text/plain',
          file_size: File.size(test_file_fixture_path)
        )

        # Need to manually set asset_type since it's normally set during a resource import
        # and we're manually creating the resource above.
        digital_object.asset_type = 'Text'
      end
    end
  end
end
