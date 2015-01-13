FactoryGirl.define do
  factory :user do
    first_name  "Automated Test"
    last_name   "User"
    email       "user@example.com"
    password    "password"
    password_confirmation    "password"
    is_admin    true
  end
end
