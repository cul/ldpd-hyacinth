# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObjectConcerns::DigitalObjectData::Setters::DynamicFieldData do
  let(:digital_object_with_sample_data) { FactoryBot.build(:digital_object_test_subclass, :with_sample_data) }
  let(:digital_object_data) do
    {
      'dynamic_field_data' => {
        'note' => [
          {
            'note_value' => 'Great Note',
            'note_type' => 'So Great'
          }
        ]
      }
    }
  end
  context '#set_dynamic_field_data' do
    it 'merges dynamic field data when merge param is true' do
      digital_object_with_sample_data.set_dynamic_field_data(digital_object_data, true)
      expect(digital_object_with_sample_data.dynamic_field_data['title']).to eq([{
        'non_sort_portion' => 'The',
        'sort_portion' => 'Tall Man and His Hat'
      }])

      expect(digital_object_with_sample_data.dynamic_field_data['note']).to eq([{
        'note_value' => 'Great Note',
        'note_type' => 'So Great'
      }])
    end

    it 'merges dynamic field data when merge param is false' do
      digital_object_with_sample_data.set_dynamic_field_data(digital_object_data, false)
      expect(digital_object_with_sample_data.dynamic_field_data['title']).to be_nil

      expect(digital_object_with_sample_data.dynamic_field_data['note']).to eq([{
        'note_value' => 'Great Note',
        'note_type' => 'So Great'
      }])
    end
  end

  context '#remove_blank_fields_from_dynamic_field_data' do
    let(:dfd_with_blank_fields) do
      {
        'alternate_title' => [
          {
            'title_non_sort_portion' => '',
            'title_sort_portion' => 'Catcher in the Rye'
          }
        ],
        'name' => [
          {
            'name_value' => '',
            'name_role' => [
              {
                'name_role_value' => ''
              }
            ]
          }
        ],
        'controlled_field_group' => [
          {
            'controlled_field' => {
              'controlled_field_uri' => '',
              'controlled_field_value' => ''
            }
          }
        ],
        'collection' => [
          {
            'collection_authorized_term_uri' => 'http://example.com/a/b/c'
          }
        ],
        'note' => [
          {
            'note_value' => '                         ', # A bunch of spaces
            'note_type' => ''
          }
        ]
      }
    end
    let(:expected_dfd_without_blank_fields) do
      {
        'alternate_title' => [
          {
            'title_sort_portion' => 'Catcher in the Rye'
          }
        ],
        'collection' => [
          {
            'collection_authorized_term_uri' => 'http://example.com/a/b/c'
          }
        ]
      }
    end
    it 'works as expected on dynamic_field_data instance variable' do
      digital_object_with_sample_data.set_digital_object_data({ 'dynamic_field_data' => dfd_with_blank_fields }, false)
      digital_object_with_sample_data.remove_blank_fields_from_dynamic_field_data!
      expect(digital_object_with_sample_data.dynamic_field_data).to eq(expected_dfd_without_blank_fields)
    end

    it 'works as expected on passed-in data' do
      digital_object_with_sample_data.remove_blank_fields_from_dynamic_field_data!(dfd_with_blank_fields)
      expect(dfd_with_blank_fields).to eq(expected_dfd_without_blank_fields)
    end
  end

  context '#trim_whitespace_for_dynamic_field_data' do
    let(:dfd_with_whitespace) do
      {
          'alternate_title' => [
            {
              'title_non_sort_portion' => 'No Extra Spaces',
              'title_sort_portion' => '    Catcher in the Rye    '
            }
          ],
          'name' => [
            {
              'name_value' => ' This has space ',
              'name_role' => [
                {
                  'name_role_value' => ' This value has spaaaace     '
                },
                {
                  'name_role_value' => 'Unchanged role without extra space'
                }
              ]
            }
          ],
          'some_field_group' => [
            {
              'some_field' => 'Great value here',
              'controlled_field' => {
                'controlled_field_uri' => '        http://id.library.columbia.edu/with/leading/space',
                'controlled_field_value' => 'Value with trailing space       '
              }
            }
          ]
        }
    end
    let(:expected_dfd_without_whitespace) do
      {
          'alternate_title' => [
            {
              'title_non_sort_portion' => 'No Extra Spaces',
              'title_sort_portion' => 'Catcher in the Rye'
            }
          ],
          'name' => [
            {
              'name_value' => 'This has space',
              'name_role' => [
                {
                  'name_role_value' => 'This value has spaaaace'
                },
                {
                  'name_role_value' => 'Unchanged role without extra space'
                }
              ]
            }
          ],
          'some_field_group' => [
            {
              'some_field' => 'Great value here',
              'controlled_field' => {
                'controlled_field_uri' => 'http://id.library.columbia.edu/with/leading/space',
                'controlled_field_value' => 'Value with trailing space'
              }
            }
          ]
        }
    end
    it 'works as expected on dynamic_field_data instance variable' do
      digital_object_with_sample_data.set_digital_object_data({ 'dynamic_field_data' => dfd_with_whitespace }, false)
      digital_object_with_sample_data.trim_whitespace_for_dynamic_field_data!
      expect(digital_object_with_sample_data.dynamic_field_data).to eq(expected_dfd_without_whitespace)
    end

    it 'works as expected on passed-in data' do
      digital_object_with_sample_data.trim_whitespace_for_dynamic_field_data!(dfd_with_whitespace)
      expect(dfd_with_whitespace).to eq(expected_dfd_without_whitespace)
    end
  end
end
