# frozen_string_literal: true

FactoryBot.define do
  factory :dynamic_field_category do
    display_label { 'Descriptive Metadata' }
    sort_order { 3 }
  end
end
