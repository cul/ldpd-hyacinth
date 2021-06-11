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
    to_create do |digital_object|
      DynamicFieldsHelper.enable_dynamic_fields(digital_object.digital_object_type, digital_object.primary_project)
      digital_object.save!
    end

    initialize_with do
      instance = new
      instance.primary_project = create(:project)
      instance
    end

    trait :with_sample_data do
      with_descriptive_metadata

      after(:build) do |digital_object|
        digital_object.instance_variable_set('@custom_field1', 'excellent value 1')
        digital_object.instance_variable_set('@custom_field2', 'excellent value 2')
      end
    end

    trait :with_descriptive_metadata do
      after(:build) do |digital_object|
        DynamicFieldsHelper.load_title_fields! # Load fields.

        digital_object.assign_descriptive_metadata({
          'descriptive_metadata' => {
            'title' => [
              {
                'non_sort_portion' => 'The',
                'sort_portion' => 'Tall Man and His Hat'
              }
            ]
          }
        })
      end
    end

    trait :with_lincoln_project do
      after(:build) do |digital_object|
        right_now = Time.current
        digital_object.primary_project = create(:project, :legend_of_lincoln, :with_publish_target, :allow_asset_rights)
        entries = digital_object.projects.map do |proj|
          proj.publish_targets.map(&:combined_key)
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
