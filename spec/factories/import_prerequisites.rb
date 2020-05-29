# frozen_string_literal: true

FactoryBot.define do
  factory :import_prerequisite do
    batch_import { FactoryBot.create(:batch_import) }
    digital_object_import do
      association :digital_object_import,
                  batch_import: batch_import,
                  index: 2
    end
    prerequisite_digital_object_import do
      association :digital_object_import,
                  batch_import: batch_import,
                  index: 1
    end
  end
end
