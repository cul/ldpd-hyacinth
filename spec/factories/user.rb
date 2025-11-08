FactoryBot.define do
  # Using a random string here so that I can run my unit tests locally without having to clear the database
  o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
  random_string = (0...50).map { o[rand(o.length)] }.join

  sequence :uid do |n|
    "test-#{random_string}-#{n}"
  end

  factory :user do
    uid
    email { "#{uid}@library.columbia.edu" }
    first_name  { "Test" }
    last_name   { "User" }
    is_active    { true }

    factory :admin_user do
      is_admin { true }
    end
    factory :non_admin_user do
      is_admin { false }
    end

    factory :inactive_user do
      is_active { false }
    end
  end
end
