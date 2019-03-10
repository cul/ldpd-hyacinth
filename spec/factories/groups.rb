FactoryBot.define do
  factory :group do
    string_key { 'great_group' }

    factory :administrators_group, class: Group do
      string_key { 'administrators' }
    end

    factory :lincoln_historical_society_group, class: Group do
      string_key { 'lincoln_historical_society' }
    end
  end
end
