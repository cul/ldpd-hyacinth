# frozen_string_literal: true

FactoryBot.define do
  factory :digital_object_import do
    index { 34 }
    digital_object_data do
      {
        'digital_object_type' => 'item',
        'dynamic_field_data' => {
          'title' => [{ 'sort_portion' => 'The', 'non_sort_portion' => 'Cool Item' }],
          'abstract' => [{ 'abstract_value' => 'some abstract' }]
        }
      }.to_json
    end

    association :batch_import, strategy: :create

    trait(:asset) do
      digital_object_data do
        {
          'digital_object_type' => 'asset',
          'dynamic_field_data' => {
            'title' => [{ 'sort_portion' => 'The', 'non_sort_portion' => 'Asset' }]
          },
          'resource_imports' => {
            'master' => {
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
        { "dynamic_field_data": { "note": [{ "value": "fantastic note" }] } }.to_json
      end
    end

    trait(:queued) do
      status { 'queued' }
      index { 30 }
      digital_object_data do
        { 'dynamic_field_data': { 'note': [{ 'value': 'another fantastic note' }] } }.to_json
      end
    end

    trait(:in_progress) do
      status { 'in_progress' }
      index { 19 }
      digital_object_data do
        { "dynamic_field_data": { "identifier": [{ "value": "something_1" }] } }.to_json
      end
    end

    trait(:success) do
      status { 'success' }
      index { 89 }
      digital_object_data do
        { "dynamic_field_data": { "date": [{ "value": "2001" }] } }.to_json
      end
    end

    trait(:failure) do
      status { 'failure' }
      index { 99 }
      import_errors { ["location.value is not a valid field"] }
      digital_object_data do
        { "dynamic_field_data": { "location": [{ "value": "some place" }] } }.to_json
      end
    end
  end
end
