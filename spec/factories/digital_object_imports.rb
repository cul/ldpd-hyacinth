# frozen_string_literal: true

FactoryBot.define do
  factory :digital_object_import do
    status { 'in_progress' }
    index  { 34 }
    digital_object_data do
      { "dynamic_field_data": { "abstract": [{ "abstract_value": "some abstract" }] } }.to_json
    end

    association :batch_import, strategy: :create

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

    trait(:pending) do
      status { 'pending' }
      index { 25 }
      digital_object_data do
        { "dynamic_field_data": { "note": [{ "value": "fantastic note" }] } }.to_json
      end
    end
  end
end
