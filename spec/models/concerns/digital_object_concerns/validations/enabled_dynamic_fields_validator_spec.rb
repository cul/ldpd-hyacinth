require 'rails_helper'

RSpec.describe DigitalObject::DynamicFieldsValidator do
  let (:item) { FactoryBot.create(:item, primary_project: FactoryBot.create(:project, :with_enabled_dynamic_field)) }

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
    item.assign_descriptive_metadata({ 'descriptive_metadata' => descriptive_metadata }, false)
  end  

    context 'when new value is being added to a descriptive field' do

    context 'when field is not enabled' do
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
  
      it ' is not valid' do
        expect(item.valid?).to be false     
      end

      it 'return errors' do
        expect(item.errors.messages).to include(
        'descriptive_metadata.alternative_title[0].value': ['must be an enabled field']
      )
      end  
    end
  end
end