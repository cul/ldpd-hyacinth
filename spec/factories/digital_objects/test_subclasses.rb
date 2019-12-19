# frozen_string_literal: true

FactoryBot.define do
  module DigitalObject
    class TestSubclass < DigitalObject::Base
      metadata_attribute :custom_field1, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'custom default value 1' }).private_writer
      metadata_attribute :custom_field2, Hyacinth::DigitalObject::TypeDef::String.new.default(-> { 'custom default value 2' })
      resource_attribute :test_resource1
      resource_attribute :test_resource2
    end
  end

  # Add ability to resolve digital object type to class
  Hyacinth::Config.digital_object_types.register('test_subclass', DigitalObject::TestSubclass)

  factory :digital_object_test_subclass, class: DigitalObject::TestSubclass do
    trait :with_sample_data do
      initialize_with do
        instance = new
        instance.instance_variable_set('@dynamic_field_data', {
          'title' => [{
            'non_sort_portion' => 'The',
            'sort_portion' => 'Tall Man and His Hat'
          }]
        })
        instance.instance_variable_set('@custom_field1', 'excellent value 1')
        instance.instance_variable_set('@custom_field2', 'excellent value 2')
        instance
      end
    end

    trait :with_lincoln_project do
      after(:build) do |digital_object|
        right_now = Time.current
        digital_object.primary_project = create(:project, :legend_of_lincoln, :with_publish_target)
        entries = digital_object.projects.map do |proj|
          proj.publish_targets.map(&:string_key)
        end.to_a.flatten.uniq.map do |sk|
          [sk, Hyacinth::PublishEntry.new(published_at: right_now, published_by: create(:user, :administrator, uid: "test-uid-#{Random.rand}"))]
        end.to_h
        digital_object.send :publish_entries=, entries.freeze
      end
    end

    trait :with_minken_project do
      after(:build) do |digital_object|
        digital_object.primary_project = create(:project, :myth_of_minken)
      end
    end
  end
end
