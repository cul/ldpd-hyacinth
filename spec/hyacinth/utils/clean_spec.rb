# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyacinth::Utils::Clean do
  describe '.trim_whitespace!' do
    let(:hash_with_whitespace) do
      {
        'alternative_title' => [
          {
            'non_sort_portion' => 'No Extra Spaces',
            'sort_portion' => '    Catcher in the Rye    '
          }
        ],
        'name' => [
          {
            'value' => ' This has space ',
            'role' => [
              {
                'value' => ' This value has spaaaace     '
              },
              {
                'value' => 'Unchanged role without extra space'
              }
            ]
          }
        ],
        'some_field_group' => [
          {
            'some_field' => 'Great value here',
            'controlled_field' => {
              'uri' => '        http://id.library.columbia.edu/with/leading/space',
              'value' => 'Value with trailing space       '
            }
          }
        ],
        'an_array_field' => ['some_value  ', '     ']
      }
    end

    let(:expected_hash_without_whitespace) do
      {
        'alternative_title' => [
          {
            'non_sort_portion' => 'No Extra Spaces',
            'sort_portion' => 'Catcher in the Rye'
          }
        ],
        'name' => [
          {
            'value' => 'This has space',
            'role' => [
              {
                'value' => 'This value has spaaaace'
              },
              {
                'value' => 'Unchanged role without extra space'
              }
            ]
          }
        ],
        'some_field_group' => [
          {
            'some_field' => 'Great value here',
            'controlled_field' => {
              'uri' => 'http://id.library.columbia.edu/with/leading/space',
              'value' => 'Value with trailing space'
            }
          }
        ],
        'an_array_field' => ['some_value', '']
      }
    end

    it 'cleans data structure as expected, modifying and returning the passed-in object' do
      expect(described_class.trim_whitespace!(hash_with_whitespace)).to eq(expected_hash_without_whitespace)
      expect(hash_with_whitespace).to eq(expected_hash_without_whitespace)
    end
  end

  describe '.remove_blank_fields!' do
    let(:hash_with_blank_fields) do
      {
        'alternative_title' => [
          {
            'non_sort_portion' => '',
            'sort_portion' => 'Catcher in the Rye'
          }
        ],
        'name' => [
          {
            'value' => '',
            'role' => [
              {
                'value' => ''
              }
            ]
          }
        ],
        'controlled_field_group' => [
          {
            'controlled_field' => {
              'uri' => '',
              'value' => ''
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
        ],
        'an_array_field' => ['', nil, 'some_value', ['', nil], true, false]
      }
    end

    let(:expected_hash_without_blank_fields) do
      {
        'alternative_title' => [
          {
            'sort_portion' => 'Catcher in the Rye'
          }
        ],
        'collection' => [
          {
            'authorized_term_uri' => 'http://example.com/a/b/c'
          }
        ],
        'an_array_field' => ['some_value', true]
      }
    end

    it 'cleans data as expected, modifying and returning the passed-in object' do
      expect(described_class.remove_blank_fields!(hash_with_blank_fields)).to eq(expected_hash_without_blank_fields)
      expect(hash_with_blank_fields).to eq(expected_hash_without_blank_fields)
    end
  end
end
