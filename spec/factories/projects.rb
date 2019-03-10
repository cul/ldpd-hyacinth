FactoryBot.define do
  factory :project do
    string_key { 'great_project' }
    display_label { 'Great Project' }

    factory :legend_of_lincoln_project do
      string_key { 'legend_of_lincoln' }
      display_label { 'Legend of Lincoln' }
    end
  end
end
