# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: DigitalObject::Item do
    initialize_with do
      instance = new
      instance.instance_variable_set(
        '@dynamic_field_data',
        {
          'title' => [
            {
              'title_non_sort_portion' => 'The',
              'title_sort_portion' => 'Best Item Ever'
            }
          ]
        }
      )
      instance
    end

    trait :with_primary_project do
      after(:build) do |digital_object|
        digital_object.primary_project = create(:project)
      end
    end

    trait :with_other_projects do
      after(:build) do |digital_object|
        ['a', 'b'].each do |val|
          digital_object.other_projects << create(
            :project,
            is_primary: false,
            string_key: "other_project_#{val}",
            display_label: "Other Project #{val.upcase}",
            project_url: "https://example.com/other_project_#{val}"
          )
        end
      end
    end
  end
end
