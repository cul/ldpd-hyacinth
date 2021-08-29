# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AsJson do
  include_context 'with stubbed search adapters'
  let(:digital_object_with_sample_data) do
    obj = FactoryBot.build(:digital_object_test_subclass, :with_sample_data)
    obj.children_to_add << FactoryBot.build(:digital_object_test_subclass, :with_sample_data)
    obj.parents_to_add << FactoryBot.build(:digital_object_test_subclass, :with_sample_data)
    obj.parents_to_add << FactoryBot.build(:digital_object_test_subclass, :with_sample_data)
    obj.save
    obj
  end
  context '#as_json' do
    include_context 'with stubbed search adapters'
    let(:expected) do
      {
        'created_at' => digital_object_with_sample_data.created_at.as_json,
        'created_by' => nil,
        'descriptive_metadata' => { "alternative_title" => [{ "value" => "Other Title" }] },
        'digital_object_type' => 'test_subclass',
        'doi' => nil,
        'first_preserved_at' => nil,
        'first_published_at' => nil,
        'identifiers' => [],
        'number_of_children' => 1,
        'other_projects' => [],
        'parents' => digital_object_with_sample_data.parents.map { |dobj| { 'uid' => dobj.uid } },
        'preserved_at' => nil,
        'primary_project' => {
          'created_at' => digital_object_with_sample_data.primary_project.created_at.as_json,
          'display_label' => digital_object_with_sample_data.primary_project.display_label,
          'has_asset_rights' => false,
          'id' => digital_object_with_sample_data.primary_project.id,
          'project_url' => digital_object_with_sample_data.primary_project.project_url,
          'string_key' => digital_object_with_sample_data.primary_project.string_key,
          'updated_at' => digital_object_with_sample_data.primary_project.updated_at.as_json
        },
        'publish_entries' => [],
        'rights' => {},
        'state' => 'active',
        'title' => { 'value' => { 'non_sort_portion' => 'The', 'sort_portion' => 'Tall Man and His Hat' } },
        'uid' => digital_object_with_sample_data.uid,
        'updated_at' => digital_object_with_sample_data.updated_at.as_json,
        'updated_by' => nil
      }
    end
    it 'produces the expected output' do
      expect(digital_object_with_sample_data.as_json).to eq(expected)
    end
  end
end
