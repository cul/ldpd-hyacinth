# frozen_string_literal: true

FactoryBot.define do
  factory :export_job do
    search_params { '{"search":"true","f":{"project_display_label_sim":["University Seminars Digital Archive"]},"page":"1"}' }
    user { User.first || create(:user) }
    path_to_export_file { '/some/path/to/file' }
    export_errors { [] }
    status { 'pending' }
    duration { 0 }
    number_of_records_processed { 0 }
    created_at { Time.current }
    updated_at { Time.current }

    trait :with_in_progress_status do
      status { 'in_progress' }
      number_of_records_processed { 1 }
      updated_at { Time.current + 1 }
      duration { 1 }
    end

    trait :with_cancelled_status do
      status { 'cancelled' }
      number_of_records_processed { 3 }
      updated_at { Time.current + 2 }
      duration { 2 }
    end

    trait :with_success_status do
      status { 'success' }
      number_of_records_processed { 100 }
      updated_at { Time.current + 10 }
      duration { 15 }
    end

    trait :with_failure_status do
      status { 'failure' }
      number_of_records_processed { 5 }
      updated_at { Time.current + 5 }
      duration { 3 }
    end
  end
end
