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

    factory :digital_object_test_subclass_with_simple_data do
      initialize_with do
        instance = new
        instance.instance_variable_set('@dynamic_field_data', {
          'title' => {
            'non_sort_portion' => 'The',
            'sort_portion' => 'Tall Man and His Hat'
          }
        })
        instance
      end
    end

    factory :digital_object_test_subclass_with_complex_data do
      initialize_with do
        legend_of_lincoln_project = build(:project, :legend_of_lincoln)

        instance = new
        instance.instance_variable_set('@uid', 'abc-111')
        instance.instance_variable_set('@doi', '10.fake/ABCDEFG')
        instance.instance_variable_set('@digital_object_type', 'test_subclass')
        instance.instance_variable_set('@state', 'active')

        instance.instance_variable_set('@created_by', build(:user, :administrator))
        instance.instance_variable_set('@updated_by', build(:user, :basic))
        instance.instance_variable_set('@last_published_by', build(:user, :basic))
        instance.instance_variable_set('@created_at', DateTime.parse('2019-02-12 8:00am'))
        instance.instance_variable_set('@updated_at', DateTime.parse('2019-02-15 9:00am'))
        instance.instance_variable_set('@first_published_at', DateTime.parse('2019-02-16 09:30am'))
        instance.instance_variable_set('@first_persisted_to_preservation_at', DateTime.parse('2019-02-16 09:30am'))
        instance.instance_variable_set('@persisted_to_preservation_at', DateTime.parse('2019-02-16 10:00am'))

        instance.instance_variable_set('@group', build(:group, :lincoln_historical_society))
        instance.instance_variable_set('@projects', Set[legend_of_lincoln_project])
        instance.instance_variable_set('@publish_targets', Set[
          build(:legend_of_lincoln_publish_target, project: legend_of_lincoln_project)]
        )
        instance.instance_variable_set('@parent_uids', Set['parent-111', 'parent-222'])
        instance.instance_variable_set('@structured_children', {
          'type' => 'sequence',
          'structure' => ['child-111', 'child-222', 'child-333']
        })
        instance.instance_variable_set('@dynamic_field_data', {
          'title' => {
            'non_sort_portion' => 'The',
            'sort_portion' => 'Tall Man and His Hat'
          }
        })
        instance.instance_variable_set('@preservation_target_uris', Set[
          'fedora3://cul:12345'
        ])
        instance.instance_variable_set('@custom_field1', 'excellent value 1')
        instance.instance_variable_set('@custom_field2', 'excellent value 2')

        instance
      end
    end
  end
end
