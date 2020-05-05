# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DynamicFieldsMap do
  describe '.generate' do
    before do
      descriptive_category = FactoryBot.create(:dynamic_field_category)
      rights_category = FactoryBot.create(:dynamic_field_category, display_label: 'Rights', metadata_form: 'item_rights')
      name_group = FactoryBot.create(:dynamic_field_group, parent: descriptive_category)
      role_group = FactoryBot.create(:dynamic_field_group, :child, parent: name_group)
      copyright_group = FactoryBot.create(:dynamic_field_group, display_label: 'Copyright Status', string_key: 'copyright_status', parent: rights_category)
      FactoryBot.create(:dynamic_field, display_label: 'Value', string_key: 'term', controlled_vocabulary: 'name', dynamic_field_group: name_group)
      FactoryBot.create(:dynamic_field, :string, display_label: 'Value', string_key: 'value', dynamic_field_group: role_group)
      FactoryBot.create(:dynamic_field, display_label: 'Copyright Statement', string_key: 'copyright_statement', controlled_vocabulary: 'rights_statement', dynamic_field_group: copyright_group)
    end

    context 'when there aren\'t any categories present' do
      subject(:map) { described_class.generate('asset_rights') }

      it 'returns empty map' do
        expect(map).to eql({})
      end
    end

    context 'when generating map for one form type' do
      subject(:map) { described_class.generate('item_rights') }

      let(:expected_map) do
        {
          "copyright_status" => {
            "type" => "DynamicFieldGroup",
            "children" => {
              "copyright_statement" => {
                'controlled_vocabulary' => "rights_statement",
                'field_type' => "controlled_term",
                'is_facetable' => true,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              }
            }
          }
        }
      end

      it 'returns complete map' do
        expect(map).to eql expected_map
      end
    end

    context 'when generating map for two form types' do
      subject(:map) { described_class.generate('descriptive', 'item_rights') }

      let(:expected_map) do
        {
          "copyright_status" => {
            "type" => "DynamicFieldGroup",
            "children" => {
              "copyright_statement" => {
                'controlled_vocabulary' => "rights_statement",
                'field_type' => "controlled_term",
                'is_facetable' => true,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              }
            }
          },
          "name" => {
            "type" => "DynamicFieldGroup",
            "children" => {
              "role" => {
                "type" => "DynamicFieldGroup",
                "children" => {
                  "value" => {
                    'controlled_vocabulary' => nil,
                    'field_type' => "string",
                    'is_facetable' => true,
                    'is_identifier_searchable' => false,
                    'is_keyword_searchable' => false,
                    'is_title_searchable' => false,
                    'select_options' => nil,
                    'type' => "DynamicField"
                  }
                }
              },
              "term" => {
                'controlled_vocabulary' => "name",
                'field_type' => "controlled_term",
                'is_facetable' => true,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              }
            }
          }
        }
      end

      it 'returns complete map' do
        expect(map).to eql expected_map
      end
    end
  end
end
