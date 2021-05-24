require 'rails_helper'

RSpec.describe DigitalObject::DynamicFieldsValidator do
  let(:project) { FactoryBot.create(:project) }
  let(:item) { FactoryBot.create(:item, primary_project: project) }

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
                { string_key: 'select_field', display_label: 'Select Field', field_type: DynamicField::Type::SELECT, select_options: '[{ "value": "text","label": "Text" }, { "value": "still image","label": "still image" }]' }
              ]
            }
          ]
        }
      ]
    }
  end

  before do
    Hyacinth::DynamicFieldsLoader.load_fields!(field_definitions, load_vocabularies: true)
    item.assign_descriptive_metadata({ 'descriptive_metadata' => descriptive_metadata }, false)
  end

  context 'when new value is being added to a descriptive field' do

    context 'when field is not enabled' do
      let(:descriptive_metadata) do
        # {
        #   'alternative_title' => [
        #     { 'value' => 'Other Title', 'sort_order' => 1 }
        #   ],
        #   'name' => [
        #     {
        #       'term' => { 'pref_label' => 'Random, Person' },
        #       'is_primary' => false,
        #       'role' => [
        #         { 'term' => { 'pref_label' => 'author' } },
        #         { 'term' => { 'pref_label' => 'writer' } }
        #       ]
        #     }
        #   ],
        #   'genre' => [
        #     { 'term' => { 'pref_label' => 'biography' } }
        #   ],
        #   'date_created' => [
        #     { 'start_date' => '2020-01-01' }
        #   ],
        #   'type_of_resource' => [{ 'value' => 'text' }]
        # }
        {
          'group1' => [
            { 'string_field' => 'A string value', 'integer_field' => 1 }
          ]
        }
      end

      before do
        FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: DynamicField.find_by_path_traversal(['group1', 'string_field']))
        FactoryBot.create(:enabled_dynamic_field, project: project, dynamic_field: DynamicField.find_by_path_traversal(['group1', 'integer_field']))
        puts '----------'
        EnabledDynamicField.all.each {|edf| puts "#{edf.dynamic_field.string_key} is enabled" }
        puts '----------'
      end

      it 'is not valid' do
        expect(item.valid?).to be false
      end

      it 'returns errors' do
        expect(item.errors.messages).to include(
        'descriptive_metadata.group1[0].string_field': ['must be an enabled field']
      )
      end
    end
  end
end
