# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::TypeDef::DynamicFieldData do
  let(:type_def) { described_class.new(:descriptive_metadata) }

  let(:field_definitions) do
    {
      dynamic_field_categories: [
        {
          display_label: 'Descriptive Metadata',
          dynamic_field_groups: [
            {
              string_key: 'name',
              display_label: 'Name',
              dynamic_fields: [
                { string_key: 'term', display_label: 'Value', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'name' },
                { string_key: 'is_primary', display_label: 'Is Primary?', field_type: DynamicField::Type::BOOLEAN }
              ],
              dynamic_field_groups: [
                {
                  string_key: 'role',
                  display_label: 'Role',
                  dynamic_fields: [
                    { string_key: 'term', display_label: 'Value', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'name_role' }
                  ]
                }
              ]
            },
            {
              string_key: 'genre',
              display_label: 'Genre',
              dynamic_fields: [
                { string_key: 'term', display_label: 'Value', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'genre' }
              ]
            }
          ]
        }
      ]
    }
  end

  let(:descriptive_metadata) do
    {
      'name' => [
        {
          'term' => {
            'prefLabel' => 'something',
            'uri' => 'temp:4712538a19c162783874c45c4682fddcf247ac031b06a98912d7df0bc43a3a54'
          },
          'is_primary' => true,
          'role' => [
            {
              'term' => {
                'pref_label' => 'author',
                'uri' => 'http://id.loc.gov/vocabulary/relators/aut'
              }
            }
          ]
        }
      ],
      'genre' => [
        {
          'term' => {
            'uri' => 'http://vocab.getty.edu/aat/300048715',
            'other_data' => 'something'
          }
        }
      ]
    }
  end

  # Load field definitions and create terms.
  before do
    Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions)
    name_vocab = Vocabulary.create(string_key: 'name', label: 'Name')
    name_vocab.add_custom_field(field_key: 'uni', label: 'UNI', data_type: 'string')
    name_vocab.save

    name_role_vocab = Vocabulary.create(string_key: 'name_role', label: 'Name Role')
    genre_vocab = Vocabulary.create(string_key: 'genre', label: 'Genre')

    Term.create!(pref_label: 'Person, Random', term_type: 'temporary', vocabulary: name_vocab, custom_fields: { uni: 'abc123' })
    Term.create!(uri: 'http://id.loc.gov/vocabulary/relators/aut', pref_label: 'Author', alt_labels: ['writer'], authority: 'marcrelator', term_type: 'external', vocabulary: name_role_vocab)
    Term.create!(uri: 'http://vocab.getty.edu/aat/300048715', pref_label: 'articles', authority: 'aat', term_type: 'external', vocabulary: genre_vocab)
  end

  describe '#from_serialized_form_impl' do
    let(:expected_serialization) do
      {
        'name' => [
          {
            'term' => {
              'pref_label' => 'Person, Random',
              'uri' => 'temp:4712538a19c162783874c45c4682fddcf247ac031b06a98912d7df0bc43a3a54',
              'authority' => nil,
              'term_type' => 'temporary',
              'alt_labels' => [],
              'uni' => 'abc123'
            },
            'is_primary' => true,
            'role' => [
              {
                'term' => {
                  'pref_label' => 'Author',
                  'uri' => 'http://id.loc.gov/vocabulary/relators/aut',
                  'authority' => 'marcrelator',
                  'term_type' => 'external',
                  'alt_labels' => ['writer']
                }
              }
            ]
          }
        ],
        'genre' => [
          {
            'term' => {
              'pref_label' => 'articles',
              'uri' => 'http://vocab.getty.edu/aat/300048715',
              'authority' => 'aat',
              'term_type' => 'external',
              'alt_labels' => []
            }
          }
        ]
      }
    end

    it 'adds term data to hash' do
      expect(type_def.from_serialized_form_impl(descriptive_metadata)).to include(expected_serialization)
    end
  end

  describe '#to_serialized_form_impl' do
    let(:expected_serialization) do
      {
        'name' => [
          {
            'term' => { 'uri' => 'temp:4712538a19c162783874c45c4682fddcf247ac031b06a98912d7df0bc43a3a54' },
            'is_primary' => true,
            'role' => [
              {
                'term' => { 'uri' => 'http://id.loc.gov/vocabulary/relators/aut' }
              }
            ]
          }
        ],
        'genre' => [
          {
            'term' => { 'uri' => 'http://vocab.getty.edu/aat/300048715' }
          }
        ]
      }
    end

    it 'removed all term data except from uri term data' do
      expect(type_def.to_serialized_form_impl(descriptive_metadata)).to include(expected_serialization)
    end
  end
end
