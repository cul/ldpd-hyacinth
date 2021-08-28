# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DigitalObject::TypeDef::DynamicFieldData do
  let(:type_def) { described_class.new(:descriptive_metadata) }

  # Create terms
  let(:name_vocab) do
    vocab = Vocabulary.create(string_key: 'name', label: 'Name')
    vocab.add_custom_field(field_key: 'uni', label: 'UNI', data_type: 'string')
    vocab.save
    vocab
  end
  let(:name_role_vocab) { Vocabulary.create(string_key: 'name_role', label: 'Name Role') }
  let(:genre_vocab) { Vocabulary.create(string_key: 'genre', label: 'Genre') }
  let(:person_term) { Term.create!(pref_label: 'Person, Random', term_type: 'temporary', vocabulary: name_vocab, custom_fields: { uni: 'abc123' }) }
  let(:role_term) do
    Term.create!(
      uri: 'http://id.loc.gov/vocabulary/relators/aut',
      pref_label: 'Author', alt_labels: ['writer'], authority: 'marcrelator',
      term_type: 'external', vocabulary: name_role_vocab
    )
  end
  let(:genre_term) { Term.create!(uri: 'http://vocab.getty.edu/aat/300048715', pref_label: 'articles', authority: 'aat', term_type: 'external', vocabulary: genre_vocab) }

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
            'uri' => person_term.uri
          },
          'is_primary' => true,
          'role' => [
            {
              'term' => {
                'pref_label' => 'author',
                'uri' => role_term.uri
              }
            }
          ]
        }
      ],
      'genre' => [
        {
          'term' => {
            'uri' => genre_term.uri,
            'other_data' => 'something'
          }
        }
      ]
    }
  end

  # Load field definitions
  before { Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions) }
  describe '#from_serialized_form_impl', solr: true do
    let(:expected_serialization) do
      {
        'name' => [
          {
            'term' => {
              'pref_label' => 'Person, Random',
              'uri' => person_term.uri,
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
                  'uri' => role_term.uri,
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
              'uri' => genre_term.uri,
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

  describe '#to_serialized_form_impl', solr: false do
    include_context 'with stubbed search adapters'
    let(:expected_serialization) do
      {
        'name' => [
          {
            'term' => { 'uri' => person_term.uri },
            'is_primary' => true,
            'role' => [
              {
                'term' => { 'uri' => role_term.uri }
              }
            ]
          }
        ],
        'genre' => [
          {
            'term' => { 'uri' => genre_term.uri }
          }
        ]
      }
    end

    it 'removed all term data except from uri term data' do
      expect(type_def.to_serialized_form_impl(descriptive_metadata)).to include(expected_serialization)
    end
  end
end
