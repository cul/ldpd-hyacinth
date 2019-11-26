# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    action     { nil }
    subject    { nil }
    subject_id { nil }
  end
end
