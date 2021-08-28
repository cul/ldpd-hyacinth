# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::DescriptiveMetadata do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
  let(:digital_object_data) do
    {
      'descriptive_metadata' => {
        'note' => [
          {
            'value' => 'Great Note',
            'type' => 'So Great'
          }
        ]
      }
    }
  end
  context '#assign_descriptive_metadata' do
    it 'merges descriptive metadata when merge param is true' do
      digital_object_with_sample_data.assign_descriptive_metadata(digital_object_data, true)
      expect(digital_object_with_sample_data.descriptive_metadata['alternate_title']).to eq([{
        'value' => 'Other Title'
      }])

      expect(digital_object_with_sample_data.descriptive_metadata['note']).to eq([{
        'value' => 'Great Note',
        'type' => 'So Great'
      }])
    end

    it 'merges descriptive metadata data when merge param is false' do
      digital_object_with_sample_data.assign_descriptive_metadata(digital_object_data, false)
      expect(digital_object_with_sample_data.descriptive_metadata['alternate_title']).to be_nil

      expect(digital_object_with_sample_data.descriptive_metadata['note']).to eq([{
        'value' => 'Great Note',
        'type' => 'So Great'
      }])
    end
  end

  context '#clean_descriptive_metadata!' do
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

    it 'works as expected on descriptive_metadata instance variable' do
      digital_object_with_sample_data.assign_attributes({ 'descriptive_metadata' => dfd }, merge_descriptive_metadata: false)
      digital_object_with_sample_data.clean_descriptive_metadata!
      expect(digital_object_with_sample_data.descriptive_metadata).to eq(cleaned_dfd)
    end
  end
end
