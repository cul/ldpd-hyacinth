FactoryBot.define do
  factory :project do
    string_key { 'great_project' }
    display_label { 'Great Project' }

    trait :legend_of_lincoln do
      string_key { 'legend_of_lincoln' }
      display_label { 'Legend of Lincoln' }
    end
  end
end
