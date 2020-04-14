# frozen_string_literal: true

FactoryBot.define do
  factory :asset, class: DigitalObject::Asset do
    parent { nil } # parent should be passed in when factory build or create or called, otherwise this object won't validate
    asset_type { BestType.dc_type.for_file_name("foo.xyz") }
    initialize_with do
      instance = new
      instance.instance_variable_set(
        '@dynamic_field_data',
        'title' => [
          {
            'non_sort_portion' => 'The',
            'sort_portion' => 'Best Asset Ever'
          }
        ]
      )
      instance.primary_project = parent.primary_project if parent
      instance.add_parent_uid(parent.uid) if parent
      instance.asset_type = asset_type
      instance
    end

    trait :with_primary_project do
      after(:build) do |digital_object|
        digital_object.primary_project = create(:project)
      end
    end

    trait :with_master_resource do
      after(:build) do |digital_object|
        test_file_fixture_path = Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s

        digital_object.resources['master'] = Hyacinth::DigitalObject::Resource.new(
          location: 'managed-disk://' + test_file_fixture_path,
          checksum: 'urn:sha256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6',
          original_file_path: test_file_fixture_path,
          media_type: 'text/plain',
          file_size: File.size(test_file_fixture_path)
        )
      end
    end
  end
end
