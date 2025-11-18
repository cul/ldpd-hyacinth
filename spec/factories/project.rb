FactoryBot.define do
  factory :project do
    transient do
      sequence :unique_id do |n|
        SecureRandom.uuid
      end
    end

    string_key { "project-#{unique_id}" }
    uri { "id.library.columbia.edu/fake/#{string_key}" }
    display_label { "Project #{unique_id}" }
    pid_generator { FactoryBot.create(:pid_generator) }
  end
end
