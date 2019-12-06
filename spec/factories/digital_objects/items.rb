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
              'non_sort_portion' => 'The',
              'sort_portion' => 'Best Item Ever'
            }
          ]
        }
      )
      instance
    end

    trait :with_project do
      after(:build) do |digital_object|
        digital_object.primary_project = create(:project)
      end
    end
  end
end
