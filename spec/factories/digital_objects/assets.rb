# frozen_string_literal: true

FactoryBot.define do
  factory :asset, class: DigitalObject::Asset do
    to_create do |asset|
      DynamicFieldsHelper.enable_dynamic_fields(asset.digital_object_type, asset.primary_project)
      asset.save!
    end

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

    trait :skip_resource_request_callbacks do
      after(:build) do |digital_object|
        digital_object.skip_resource_request_callbacks = true
      end
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
          location: 'tracked-disk://' + test_file_fixture_path,
          checksum: 'sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2',
          original_file_path: test_file_fixture_path,
          media_type: 'text/plain',
          file_size: File.size(test_file_fixture_path)
        )

        # Need to manually set asset_type since it's normally set during a resource import
        # and we're manually creating the resource above.
        digital_object.asset_type = 'Text'
      end
    end

    trait :with_service_resource do
      after(:build) do |digital_object|
        test_file_fixture_path = Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s

        digital_object.resources['service'] = Hyacinth::DigitalObject::Resource.new(
          location: 'tracked-disk://' + test_file_fixture_path,
          checksum: 'sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2',
          original_file_path: test_file_fixture_path,
          media_type: 'text/plain',
          file_size: File.size(test_file_fixture_path)
        )
      end
    end

    trait :with_access_resource do
      after(:build) do |digital_object|
        test_file_fixture_path = Rails.root.join('spec', 'fixtures', 'files', 'test.pdf').to_s

        digital_object.resources['access'] = Hyacinth::DigitalObject::Resource.new(
          location: 'tracked-disk://' + test_file_fixture_path,
          checksum: 'sha256:348c166ea8b30c780add29f2d42e961174f23c87b0851621de5019799347b063',
          original_file_path: test_file_fixture_path,
          media_type: 'text/plain',
          file_size: File.size(test_file_fixture_path)
        )
      end
    end

    trait :with_poster_resource do
      after(:build) do |digital_object|
        test_file_fixture_path = Rails.root.join('spec', 'fixtures', 'files', 'test.png').to_s

        digital_object.resources['poster'] = Hyacinth::DigitalObject::Resource.new(
          location: 'tracked-disk://' + test_file_fixture_path,
          checksum: 'sha256:401bc02419abb53a29eee7c4fa1050a9c4146a5b3723e5fcfc8088d624d20184',
          original_file_path: test_file_fixture_path,
          media_type: 'text/plain',
          file_size: File.size(test_file_fixture_path)
        )
      end
    end

    trait :with_fulltext_resource do
      after(:build) do |digital_object|
        test_file_fixture_path = Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s

        digital_object.resources['fulltext'] = Hyacinth::DigitalObject::Resource.new(
          location: 'tracked-disk://' + test_file_fixture_path,
          checksum: 'sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2',
          original_file_path: test_file_fixture_path,
          media_type: 'text/plain',
          file_size: File.size(test_file_fixture_path)
        )
      end
    end
  end
end
