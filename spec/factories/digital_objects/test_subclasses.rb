FactoryBot.define do
  module DigitalObject
    class TestSubclass < DigitalObject::Base
      metadata_attribute :custom_field1, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'custom default value 1' })
      metadata_attribute :custom_field2, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'custom default value 2' }).public_writer
      resource_attribute :test_resource1
      resource_attribute :test_resource2
    end
  end

  # Add ability to resolve digital object type to class
  Hyacinth.config.digital_object_types.register('test_subclass', DigitalObject::TestSubclass)

  factory :digital_object_test_subclass, class: DigitalObject::TestSubclass do
    to_create { |instance| instance.save }

    trait :with_sample_data do
      initialize_with do
        instance = new
        instance.instance_variable_set('@dynamic_field_data', {
          'title' => {
            'non_sort_portion' => 'The',
            'sort_portion' => 'Tall Man and His Hat'
          }
        })
        instance.instance_variable_set('@custom_field1', 'excellent value 1')
        instance.instance_variable_set('@custom_field2', 'excellent value 2')
        instance
      end
    end
  end
end
