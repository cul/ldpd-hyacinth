# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DynamicFieldsLoader do
  context '.load_fields!' do
    let(:field_definitions) do
      {
        dynamic_field_categories: [{
          display_label: 'Descriptive Metadata',
          dynamic_field_groups: [
            {
              string_key: 'name',
              display_label: 'Name',
              dynamic_fields: [
                { string_key: 'is_primary', display_label: "Is Primary?", field_type: DynamicField::Type::BOOLEAN }
              ],
              dynamic_field_groups: [
                {
                  string_key: 'role',
                  display_label: 'Role',
                  dynamic_fields: [
                    { string_key: 'term', display_label: 'Term', field_type: DynamicField::Type::CONTROLLED_TERM, controlled_vocabulary: 'name_role' }
                  ]
                }
              ]
            }
          ]
        }]
      }
    end

    context 'when no fields are defined' do
      before { described_class.load_fields!(field_definitions, load_vocabularies: true) }

      let(:category) { DynamicFieldCategory.find_by(display_label: 'Descriptive Metadata') }
      let(:name_group) { category.dynamic_field_groups.find_by(string_key: 'name') }
      let(:role_group) { name_group.dynamic_field_groups.find_by(string_key: 'role') }

      it 'loads all expected fields' do
        expect(category).not_to be nil
        expect(name_group).not_to be nil
        expect(role_group).not_to be nil
        expect(name_group.dynamic_fields.find_by(string_key: 'is_primary')).not_to be nil
        expect(role_group.dynamic_fields.find_by(string_key: 'term')).not_to be nil
      end

      it 'loads vocabularies' do
        expect(Vocabulary.find_by(string_key: 'name_role', label: 'Name Role')).not_to be nil
      end
    end

    context 'when some fields are defined' do
      before do
        category = DynamicFieldCategory.create(display_label: 'Descriptive Metadata')
        DynamicFieldGroup.create(string_key: 'name', display_label: 'Name', parent: category)

        described_class.load_fields!(field_definitions)
      end

      it 'does not create an additional dynamic field category' do
        expect(DynamicFieldCategory.count).to be 1
      end

      it 'does not create an additional dynamic field group' do
        expect(DynamicFieldGroup.count).to be 2
      end
    end

    context 'when fields are missing information' do
      it 'returns an error' do
        field_definitions[:dynamic_field_categories][0].delete(:display_label)
        expect {
          described_class.load_fields!(field_definitions)
        }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Display label can\'t be blank'
      end
    end
  end
end
