# frozen_string_literal: true

FactoryBot.define do
  factory :digital_object_import do
    status { 1 } # in_progress
    index  { 34 }
    digital_object_data do
      { "abstract": [{ "abstract_value": "some abstract" }] }.to_json
    end

    association :batch_import, strategy: :create

    trait(:in_progress) do
      status { 1 }
      index { 19 }
      digital_object_data do
        { "identifier": [{ "value": "something_1" }] }.to_json
      end
    end

    trait(:success) do
      status { 2 }
      index { 89 }
      digital_object_data do
        { "date": [{ "value": "2001" }] }.to_json
      end
    end

    trait(:failure) do
      status { 3 }
      index { 99 }
      import_errors { ["location.value is not a valid field"] }
      digital_object_data do
        { "location": [{ "value": "some place" }] }.to_json
      end
    end

    trait(:pending) do
      status { 0 }
      index { 25 }
      digital_object_data do
        { "note": [{ "value": "fantastic note" }] }.to_json
      end
    end
  end
end
