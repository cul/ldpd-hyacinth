# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalObject::DynamicFieldsValidator do
  let(:project) { FactoryBot.create(:project) }
  let(:item) { FactoryBot.build(:item, primary_project: project, descriptive_metadata: descriptive_metadata) }

  # Setting up descriptive_metadata fields
  let(:field_definitions) do
    {
      dynamic_field_categories: [
        {
          display_label: 'Sample Dynamic Field Category',
          dynamic_field_groups: [
            {
              string_key: 'group1',
              display_label: 'Group 1',
              dynamic_fields: [
                { string_key: 'string_field', display_label: 'String Field', field_type: DynamicField::Type::STRING },
                { string_key: 'integer_field', display_label: 'Integer Field', field_type: DynamicField::Type::INTEGER }
              ]
            },
            {
              string_key: 'group2',
              display_label: 'Group 2',
              dynamic_fields: [
                { string_key: 'controlled_term_field', display_label: 'Controlled Term Field', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'name' },
                { string_key: 'boolean_field', display_label: 'Boolean Field', field_type: DynamicField::Type::BOOLEAN }
              ],
              dynamic_field_groups: [
                {
                  string_key: 'group2_1',
                  display_label: 'Group 2.1',
                  dynamic_fields: [
                    { string_key: 'controlled_term_field', display_label: 'Controlled Term Field', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'name_role' }
                  ]
                }
              ]
            },
            {
              string_key: 'group3',
              display_label: 'Group 3',
              dynamic_fields: [
                { string_key: 'controlled_term_field', display_label: 'Controlled Term Field', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'genre' }
              ]
            },
            {
              string_key: 'group4',
              display_label: 'Group 4',
              dynamic_fields: [
                { string_key: 'date_field', display_label: 'Date Field', field_type: DynamicField::Type::DATE }
              ]
            },
            {
              string_key: 'group5',
              display_label: 'Group 5',
              dynamic_fields: [
                {
                  string_key: 'select_field', display_label: 'Select Field', field_type: DynamicField::Type::SELECT, select_options:
                  '[{ "value": "text","label": "Text" }, { "value": "still image","label": "still image" }]'
                }
              ]
            }
          ]
        }
      ]
    }
  end

  context 'when new values are being added to a descriptive field' do
    before do
      Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions, load_vocabularies: true)

      FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: DynamicField.find_by_path_traversal(['group2', 'controlled_term_field']))
      FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: DynamicField.find_by_path_traversal(['group2', 'boolean_field']))
    end

    context 'when some of the assigned fields in the data are not enabled' do
      let(:descriptive_metadata) do
        {
          'group1' => [
            {
              'string_field' => 'A string value',
              'integer_field' => 1
            }
          ],
          'group2' => [
            {
              'controlled_term_field' => { 'uri' => 'https://www.example.com' },
              'boolean_field' => true
            }
          ]
        }
      end

      it 'sets the expected errors on the digital object' do
        expect(item.valid?).to be false
        expect(item.errors.to_hash).to eq(
          'group1/string_field': ['field must be enabled'],
          'group1/integer_field': ['field must be enabled']
        )
      end
    end

    context 'when the assigned data is missing a required field' do
      let(:descriptive_metadata) do
        {
          'group2' => [
            {
              'boolean_field' => true
            }
          ]
        }
      end

      it 'sets the expected errors on the digital object' do
        expect(item.valid?).to be false
        expect(item.errors.to_hash).to eq(
          "group2/controlled_term_field": ["is required"]
        )
      end
    end
  end
end
