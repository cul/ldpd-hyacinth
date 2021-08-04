# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObject::DescriptiveFieldsValidator do
  let(:item) { FactoryBot.build(:item, :with_ascii_title, descriptive_metadata: descriptive_metadata) }

  # Setting up descriptive_metadata fields
  let(:field_definitions) do
    {
      dynamic_field_categories: [
        {
          display_label: 'Descriptive Metadata',
          dynamic_field_groups: [
            {
              string_key: 'alternative_title',
              display_label: 'Alternative Title',
              dynamic_fields: [
                { string_key: 'value', display_label: 'Value', field_type: DynamicField::Type::STRING },
                { string_key: 'sort_order', display_label: 'Sort Order', field_type: DynamicField::Type::INTEGER }
              ]
            },
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
                  is_repeatable: 'true',
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
            },
            {
              string_key: 'date_created',
              display_label: 'Date Created',
              dynamic_fields: [
                { string_key: 'start_date', display_label: 'Start Date', field_type: DynamicField::Type::DATE }
              ]
            },
            {
              string_key: 'type_of_resource',
              display_label: 'Type of Resource',
              dynamic_fields: [
                { string_key: 'value', display_label: 'Value', field_type: DynamicField::Type::SELECT, select_options: '[{ "value": "text","label": "Text" }, { "value": "still image","label": "still image" }]' }
              ]
            }
          ]
        }
      ]
    }
  end

  before do
    Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions, load_vocabularies: true)
  end

  context 'with correct structure' do
    let(:descriptive_metadata) do
      {
        'alternative_title' => [
          { 'value' => 'Other Title', 'sort_order' => 1 }
        ],
        'name' => [
          {
            'term' => { 'pref_label' => 'Random, Person' },
            'is_primary' => false,
            'role' => [
              { 'term' => { 'pref_label' => 'author' } },
              { 'term' => { 'pref_label' => 'writer' } }
            ]
          }
        ],
        'genre' => [
          { 'term' => { 'pref_label' => 'biography' } }
        ],
        'date_created' => [
          { 'start_date' => '2020-01-01' }
        ],
        'type_of_resource' => [{ 'value' => 'text' }]
      }
    end

    it 'validates' do
      DynamicFieldsHelper.enable_dynamic_fields(item.digital_object_type, item.primary_project)
      expect(item.valid?).to be true
    end
  end

  context 'with invalid value in terms hash' do
    let(:descriptive_metadata) do
      {
        'name' => [
          { 'role' => [{ 'term' => 'author' }] }
        ]
      }
    end

    it 'returns errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.name[0].role[0].term': ['must be a controlled term']
      )
    end
  end

  context 'with invalid fields in terms hash' do
    let(:descriptive_metadata) do
      {
        'name' => [
          {
            'role' => [
              { 'term' => { 'pref_label' => 'author', 'other_field' => 'some value', 'other_field_2' => 'some other value' } }
            ]
          }
        ]
      }
    end

    it 'returns errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.name[0].role[0].term': ['has invalid key, "other_field" in hash', 'has invalid key, "other_field_2" in hash']
      )
    end
  end

  context 'when field does not exist' do
    let(:descriptive_metadata) do
      {
        'name' => [
          { 'role' => [{ 'value' => 'author' }] }
        ]
      }
    end

    it 'returns errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.name[0].role[0].value': ['is not a valid field']
      )
    end
  end

  context 'when term data does not contain a uri or pref label' do
    let(:descriptive_metadata) do
      {
        'name' => [
          {
            'role' => [
              { 'term' => { 'prefLabel' => 'author', 'other_field' => 'some value' } }
            ]
          }
        ]
      }
    end

    it 'returns errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.name[0].role[0].term': ['must contain a uri or pref_label']
      )
    end
  end

  context 'with fields with an invalid vocabulary' do
    it 'return errors'
  end

  context 'with incorrectly structured data' do
    let(:descriptive_metadata) do
      {
        'name' => [
          { 'role' => { 'term' => 'author' } }
        ]
      }
    end

    it 'return errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.name[0].role': ['must contain an array']
      )
    end
  end

  context 'with invalid value for a boolean field' do
    let(:descriptive_metadata) do
      { 'name' => [{ 'is_primary' => 'unknown' }] }
    end

    it 'return errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.name[0].is_primary': ['must be a boolean']
      )
    end
  end

  context 'with invalid value for an integer field' do
    let(:descriptive_metadata) do
      {
        'alternative_title' => [
          { 'sort_order' => '123' }
        ]
      }
    end

    it 'returns errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.alternative_title[0].sort_order': ['must be an integer']
      )
    end
  end

  context 'with invalid value for select field' do
    let(:descriptive_metadata) do
      {
        'type_of_resource': [
          { value: 'not_valid' }
        ]
      }
    end

    it 'returns errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.type_of_resource[0].value': ["has invalid value: 'not_valid'"]
      )
    end
  end

  context 'with invalid value for a string field' do
    let(:descriptive_metadata) do
      { 'alternative_title': [{ value: 5 }] }
    end

    it 'return errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.alternative_title[0].value': ['must be a string']
      )
    end
  end

  context 'with valid EDTF dates of varying specificity' do
    [
      '1900-01-01', '1900-01', '1900',
      '-1900-01-01', '-1900-01', '-1900',
      '190X', '19XX', '000X', '00XX',
      '1900-01-XX', '1900-XX'
    ].each do |date|
      context "date = #{date}" do
        let(:descriptive_metadata) do
          { 'date_created' => [{ 'start_date' => date }] }
        end

        it 'is valid' do
          item.validate
          expect(item.errors.full_messages).to be_blank
        end
      end
    end
  end

  context 'with impossible-date EDTF dates of varying specificity' do
    [
      '1900-15-15', '1900-15',
      '-1900-15-15', '-1900-15',
      '1900-01-40', '-1900-01-40',
      '1900-15-XX'
    ].each do |date|
      context "date = #{date}" do
        let(:descriptive_metadata) do
          { 'date_created' => [{ 'start_date' => date }] }
        end

        it 'is not valid' do
          expect(item.valid?).to eq(false)
        end
      end
    end
  end

  context 'with non-string value for date field' do
    let(:descriptive_metadata) do
      { 'date_created' => [{ 'start_date' => 123 }] }
    end

    it 'return errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.date_created[0].start_date': ['must be a string']
      )
    end
  end

  context 'with invalid format for date field' do
    let(:descriptive_metadata) do
      { 'date_created' => [{ 'start_date' => '09-09-2009' }] }
    end

    it 'return errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.date_created[0].start_date': ['must be a valid EDTF date']
      )
    end
  end

  context 'with invalid date for date field' do
    let(:descriptive_metadata) do
      { 'date_created' => [{ 'start_date' => '2009-02-31' }] }
    end

    it 'return errors' do
      expect(item.valid?).to be false
      expect(item.errors.messages).to include(
        'descriptive_metadata.date_created[0].start_date': ['must be a valid EDTF date']
      )
    end
  end
end
