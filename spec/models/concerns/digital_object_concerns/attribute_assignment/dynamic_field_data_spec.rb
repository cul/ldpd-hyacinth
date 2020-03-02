# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::DynamicFieldData do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
  let(:digital_object_data) do
    {
      'dynamic_field_data' => {
        'note' => [
          {
            'value' => 'Great Note',
            'type' => 'So Great'
          }
        ]
      }
    }
  end
  context '#assign_dynamic_field_data' do
    it 'merges dynamic field data when merge param is true' do
      digital_object_with_sample_data.assign_dynamic_field_data(digital_object_data, true)
      expect(digital_object_with_sample_data.dynamic_field_data['title']).to eq([{
        'non_sort_portion' => 'The',
        'sort_portion' => 'Tall Man and His Hat'
      }])

      expect(digital_object_with_sample_data.dynamic_field_data['note']).to eq([{
        'value' => 'Great Note',
        'type' => 'So Great'
      }])
    end

    it 'merges dynamic field data when merge param is false' do
      digital_object_with_sample_data.assign_dynamic_field_data(digital_object_data, false)
      expect(digital_object_with_sample_data.dynamic_field_data['title']).to be_nil

      expect(digital_object_with_sample_data.dynamic_field_data['note']).to eq([{
        'value' => 'Great Note',
        'type' => 'So Great'
      }])
    end
  end

  context '#clean_dynamic_field_data!' do
    let(:dfd) do
      {
        'alternate_title' => [
          {
            'non_sort_portion' => '',
            'sort_portion' => '    Catcher in the Rye    '
          }
        ],
        'name' => [
          {
            'value' => ' Random, Person ',
            'role' => [
              {
                'value' => ' Author     '
              },
              {
                'value' => ''
              }
            ]
          }
        ],
        'controlled_field_group' => [
          {
            'controlled_field' => {
              'uri' => '        http://id.library.columbia.edu/with/leading/space',
              'value' => 'Great value here'
            }
          }
        ],
        'collection' => [
          {
            'authorized_term_uri' => 'http://example.com/a/b/c'
          }
        ],
        'note' => [
          {
            'value' => '                         ', # A bunch of spaces
            'type' => ''
          }
        ]
      }
    end
    let(:cleaned_dfd) do
      {
        'alternate_title' => [
          {
            'sort_portion' => 'Catcher in the Rye'
          }
        ],
        'name' => [
          {
            'value' => 'Random, Person',
            'role' => [
              {
                'value' => 'Author'
              }
            ]
          }
        ],
        'controlled_field_group' => [
          {
            'controlled_field' => {
              'uri' => 'http://id.library.columbia.edu/with/leading/space',
              'value' => 'Great value here'
            }
          }
        ],
        'collection' => [
          {
            'authorized_term_uri' => 'http://example.com/a/b/c'
          }
        ]
      }
    end

    it 'works as expected on dynamic_field_data instance variable' do
      digital_object_with_sample_data.assign_attributes({ 'dynamic_field_data' => dfd }, merge_dynamic_field_data: false)
      digital_object_with_sample_data.clean_dynamic_field_data!
      expect(digital_object_with_sample_data.dynamic_field_data).to eq(cleaned_dfd)
    end
  end
end
