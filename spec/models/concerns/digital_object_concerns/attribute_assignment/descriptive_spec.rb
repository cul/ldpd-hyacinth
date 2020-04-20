# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::AttributeAssignment::Descriptive do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
  let(:digital_object_data) do
    {
      'descriptive' => {
        'note' => [
          {
            'value' => 'Great Note',
            'type' => 'So Great'
          }
        ]
      }
    }
  end
  context '#assign_descriptive' do
    it 'merges descriptive data when merge param is true' do
      digital_object_with_sample_data.assign_descriptive(digital_object_data, true)
      expect(digital_object_with_sample_data.descriptive['title']).to eq([{
        'non_sort_portion' => 'The',
        'sort_portion' => 'Tall Man and His Hat'
      }])

      expect(digital_object_with_sample_data.descriptive['note']).to eq([{
        'value' => 'Great Note',
        'type' => 'So Great'
      }])
    end

    it 'merges descriptive data when merge param is false' do
      digital_object_with_sample_data.assign_descriptive(digital_object_data, false)
      expect(digital_object_with_sample_data.descriptive['title']).to be_nil

      expect(digital_object_with_sample_data.descriptive['note']).to eq([{
        'value' => 'Great Note',
        'type' => 'So Great'
      }])
    end
  end

  context '#clean_descriptive!' do
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
    let(:cleaned_descriptive) do
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

    it 'works as expected on descriptive instance variable' do
      digital_object_with_sample_data.assign_attributes({ 'descriptive' => dfd }, merge_descriptive: false)
      digital_object_with_sample_data.clean_descriptive!
      expect(digital_object_with_sample_data.descriptive).to eq(cleaned_descriptive)
    end
  end
end
