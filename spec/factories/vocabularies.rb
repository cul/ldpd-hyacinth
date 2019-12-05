# frozen_string_literal: true

FactoryBot.define do
  factory :vocabulary do
    label      { 'Mythical Creatures' }
    string_key { 'mythical_creatures' }
    custom_fields {}

    trait :with_custom_field do
      custom_fields do
        {
          harry_potter_reference: {
            label: 'Harry Potter Reference',
            data_type: 'boolean'
          }
        }
      end
    end
  end
end
