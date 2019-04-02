FactoryBot.define do
  factory :dynamic_field_group do
    string_key      { 'name' }
    display_label   { 'Name' }
    is_repeatable   { true }
    xml_translation {}
    sort_order      { 3 }

    created_by      { User.first || create(:user) }
    updated_by      { User.first || create(:user) }

    association :parent, factory: :dynamic_field_category, strategy: :create

    trait(:child) do
      string_key    { 'role' }
      display_label { 'Role' }

      parent        { nil }
    end
  end
end
