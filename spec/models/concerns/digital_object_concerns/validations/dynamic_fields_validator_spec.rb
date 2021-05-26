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
      # that only a single value is supplied for a non-repeatable field (for descriptive AND rights fields)
    context 'when multiple values are being added to a non-repeatable field' do
      let(:descriptive_metadata) do
        {
          'group1' => [
            { 'string_field' => 'A string value', 'integer_field' => 1 },
            { 'string_field' => 'Another string value', 'integer_field' => 2 }
          ]
        }
      end
  
      it 'returns errors' do
          expect(item.valid?).to be false
          expect(item.errors.messages).to include(
            'descriptive_metadata.group1': ['is not repeatable']
          )
      end  
    end
  end
end
