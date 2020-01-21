# frozen_string_literal: true

FactoryBot.define do
  factory :asset, class: DigitalObject::Asset do
    parent { nil } # parent should be passed in when factory build or create or called, otherwise this object won't validate
    asset_type { BestType.dc_type.for_file_name("foo.xyz") }
    initialize_with do
      instance = new
      instance.instance_variable_set(
        '@dynamic_field_data',
        'title' => [
          {
            'non_sort_portion' => 'The',
            'sort_portion' => 'Best Asset Ever'
          }
        ]
      )
      instance.instance_variable_set('@primary_project', parent.primary_project)
      instance.primary_project = parent.primary_project
      instance.add_parent_uid(parent.uid)
      instance.asset_type = asset_type
      instance
    end
  end
end
