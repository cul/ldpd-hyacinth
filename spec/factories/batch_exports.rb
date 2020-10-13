# frozen_string_literal: true

FactoryBot.define do
  factory :batch_export do
    search_params { '{"digital_object_type_ssi":["item"],"q":null}' }
    export_filter_config { nil }
    file_location { nil }
    user { User.first || create(:user) }
    export_errors { [] }
    status { 'pending' }
    duration { 0 }
    number_of_records_processed { 0 }
    total_records_to_process { 0 }
    created_at { Time.current }
    updated_at { Time.current }

    trait :in_progress do
      status { 'in_progress' }
      number_of_records_processed { 1 }
      total_records_to_process { 100 }
      updated_at { Time.current + 1 }
      duration { 1 }
    end

    trait :cancelled do
      status { 'cancelled' }
      number_of_records_processed { 3 }
      total_records_to_process { 100 }
      updated_at { Time.current + 2 }
      duration { 2 }
    end

    trait :success do
      file_location { 'managed-disk:///some/path/to/file' }
      status { 'success' }
      number_of_records_processed { 100 }
      total_records_to_process { 100 }
      updated_at { Time.current + 10 }
      duration { 15 }
    end

    trait :failure do
      status { 'failure' }
      export_errors { ['An error'] }
      number_of_records_processed { 5 }
      total_records_to_process { 100 }
      updated_at { Time.current + 5 }
      duration { 3 }
    end
  end
end
