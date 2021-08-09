# frozen_string_literal: true

FactoryBot.define do
  factory :digital_object_import do
    index { 34 }
    digital_object_data do
      {
        'digital_object_type' => 'item',
        'descriptive_metadata' => {
          'title' => [{ 'sort_portion' => 'The', 'non_sort_portion' => 'Cool Item' }],
          'abstract' => [{ 'value' => 'some abstract' }]
        },
        'primary_project' => {
          'string_key' => FactoryBot.create(:project).string_key
        }
      }.to_json
    end

    after(:build) do
      DynamicFieldsHelper.load_title_fields!
      DynamicFieldsHelper.load_abstract_fields!
    end

    association :batch_import, strategy: :create

    trait(:asset) do
      digital_object_data do
        {
          'digital_object_type' => 'asset',
          'descriptive_metadata' => {
            'title' => [{ 'sort_portion' => 'The', 'non_sort_portion' => 'Asset' }]
          },
          'primary_project' => {
            'string_key' => FactoryBot.create(:project).string_key
          },
          'resource_imports' => {
            'main' => {
              method: 'copy',
              location: Rails.root.join('spec', 'fixtures', 'files', 'test.txt')
            }
          }
        }.to_json
      end
    end

    trait(:pending) do
      status { 'pending' }
      index { 25 }
      digital_object_data do
        {
          "descriptive_metadata": { "note": [{ "value": "fantastic note" }] },
          'primary_project' => {
            'string_key' => FactoryBot.create(:project).string_key
          }
        }.to_json
      end
    end

    trait(:queued) do
      status { 'queued' }
      index { 30 }
      digital_object_data do
        {
          'descriptive_metadata': { 'note': [{ 'value': 'another fantastic note' }] },
          'primary_project' => {
            'string_key' => FactoryBot.create(:project).string_key
          }
        }.to_json
      end
    end

    trait(:in_progress) do
      status { 'in_progress' }
      index { 19 }
      digital_object_data do
        {
          "descriptive_metadata": { "identifier": [{ "value": "something_1" }] },
          'primary_project' => {
            'string_key' => FactoryBot.create(:project).string_key
          }
        }.to_json
      end
    end

    trait(:success) do
      status { 'success' }
      index { 89 }
      digital_object_data do
        {
          "descriptive_metadata": { "date": [{ "value": "2001" }] },
          'primary_project' => {
            'string_key' => FactoryBot.create(:project).string_key
          }
        }.to_json
      end
    end

    trait(:creation_failure) do
      status { 'creation_failure' }
      index { 99 }
      import_errors { ["location.value is not a valid field"] }
      digital_object_data do
        {
          "descriptive_metadata": { "location": [{ "value": "some place" }] },
          'primary_project' => {
            'string_key' => FactoryBot.create(:project).string_key
          }
        }.to_json
      end
    end
  end
end
