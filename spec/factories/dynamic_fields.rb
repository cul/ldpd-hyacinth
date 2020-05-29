# frozen_string_literal: true

FactoryBot.define do
  factory :dynamic_field do
    string_key      { 'term' }
    display_label   { 'Value' }
    field_type      { DynamicField::Type::CONTROLLED_TERM }
    sort_order      { 7 }
    filter_label    { 'Name' }

    is_facetable             { true }
    controlled_vocabulary    { 'name_role' }
    select_options           { nil }
    is_keyword_searchable    { false }
    is_title_searchable      { false }
    is_identifier_searchable { false }

    created_by      { User.first || create(:user) }
    updated_by      { User.first || create(:user) }

    association :dynamic_field_group, factory: :dynamic_field_group, strategy: :create

    trait :string do
      field_type { DynamicField::Type::STRING }
      controlled_vocabulary { nil }
    end
  end
end
