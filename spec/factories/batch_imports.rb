# frozen_string_literal: true

FactoryBot.define do
  factory :batch_import do
    file_location { 'managed-disk://path/to/file' }

    priority { 'high' }
    cancelled { false }

    association :user, strategy: :create

    trait(:with_digital_object_import) do
      after(:create) do |batch_import|
        create(:digital_object_import, batch_import: batch_import)
      end
    end
  end
end
