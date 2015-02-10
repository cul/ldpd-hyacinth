FactoryGirl.define do
  sequence :email do |n|
    "test#{n}@library.columbia.edu"
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
