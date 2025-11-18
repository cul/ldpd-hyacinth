FactoryBot.define do
  factory :pid_generator do
    sequence :namespace do |n|
      "test#{n}"
    end
  end
end
