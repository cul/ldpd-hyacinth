# frozen_string_literal: true

FactoryBot.define do
  factory :dynamic_field_group do
    string_key      { 'name' }
    display_label   { 'Name' }
    is_repeatable   { true }
    sort_order      { 3 }

    created_by      { User.first || create(:user) }
    updated_by      { User.first || create(:user) }

    association :parent, factory: :dynamic_field_category, strategy: :create

    trait(:child) do
      string_key    { 'role' }
      display_label { 'Role' }

      parent        { nil }
    end

    trait(:with_export_rule) do
      after(:create) do |dynamic_field_group|
        create(:export_rule, dynamic_field_group: dynamic_field_group)
      end
    end
  end
end
