# frozen_string_literal: true

FactoryBot.define do
  factory :enabled_dynamic_field do
    association :project
    association :dynamic_field

    field_sets { [] }
    digital_object_type { 'item' }
    required            { true }
    locked              { false }
    hidden              { false }
    owner_only          { false }
    shareable           { false }
    default_value       {}
  end
end
