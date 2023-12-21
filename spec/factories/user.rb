FactoryBot.define do

  # Using a random string here so that I can run my unit tests locally without having to clear the database
  o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
  random_string = (0...50).map { o[rand(o.length)] }.join

  sequence :email do |n|
    "test-#{random_string}-#{n}@library.columbia.edu"
  end

  factory :user do
    email
    first_name  "Test"
    last_name   "User"
    password    "password"
    password_confirmation    "password"

    factory :admin_user do
      is_admin    true
    end
    factory :non_admin_user do
      is_admin    false
    end

  end
end
