# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DynamicFieldsMap do
  before do
    descriptive_category = FactoryBot.create(:dynamic_field_category)
    rights_category = FactoryBot.create(:dynamic_field_category, display_label: 'Rights', metadata_form: 'item_rights')
    name_group = FactoryBot.create(:dynamic_field_group, parent: descriptive_category)
    role_group = FactoryBot.create(:dynamic_field_group, :child, parent: name_group)
    copyright_group = FactoryBot.create(:dynamic_field_group, display_label: 'Copyright Status', string_key: 'copyright_status', parent: rights_category)
    FactoryBot.create(:dynamic_field, display_label: 'Value', string_key: 'term', controlled_vocabulary: 'name', dynamic_field_group: name_group)
    FactoryBot.create(:dynamic_field, :string, display_label: 'Value', string_key: 'value', dynamic_field_group: role_group)
    FactoryBot.create(:dynamic_field, display_label: 'Copyright Statement', string_key: 'copyright_statement',
                                      controlled_vocabulary: 'rights_statement', dynamic_field_group: copyright_group, filter_label: nil)
  end

  describe '#map' do
    context 'when there aren\'t any categories present' do
      subject(:map) { described_class.new('asset_rights').map }

      it 'returns empty map' do
        expect(map).to eql({})
      end
    end

    context 'when generating map for one form type' do
      subject(:map) { described_class.new('item_rights').map }

      let(:expected_map) do
        {
          "copyright_status" => {
            "type" => "DynamicFieldGroup",
            "children" => {
              "copyright_statement" => {
                'filter_label' => nil,
                'display_label' => 'Copyright Statement',
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
      subject(:map) { described_class.new('descriptive', 'item_rights').map }

      let(:expected_map) do
        {
          "copyright_status" => {
            "type" => "DynamicFieldGroup",
            "children" => {
              "copyright_statement" => {
                'display_label' => 'Copyright Statement',
                'filter_label' => nil,
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
                    'display_label' => 'Value',
                    'filter_label' => nil,
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
                'display_label' => 'Value',
                'filter_label' => 'Name',
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

  describe '#all_fields' do
    context 'when generating field list for two form types' do
      subject(:all_fields) { described_class.new('descriptive', 'item_rights').all_fields }

      let(:expected_fields) do
        [
          {
            'path' => ['copyright_status', 'copyright_statement'],
            'display_label' => 'Copyright Statement',
            'filter_label' => nil,
            'controlled_vocabulary' => "rights_statement",
            'field_type' => "controlled_term",
            'is_facetable' => true,
            'is_identifier_searchable' => false,
            'is_keyword_searchable' => false,
            'is_title_searchable' => false,
            'select_options' => nil,
            'type' => "DynamicField"
          },
          {
            'path' => ['name', 'role', 'value'],
            'display_label' => 'Value',
            'filter_label' => nil,
            'controlled_vocabulary' => nil,
            'field_type' => "string",
            'is_facetable' => true,
            'is_identifier_searchable' => false,
            'is_keyword_searchable' => false,
            'is_title_searchable' => false,
            'select_options' => nil,
            'type' => "DynamicField"
          },
          {
            'path' => ['name', 'term'],
            'display_label' => 'Value',
            'filter_label' => 'Name',
            'controlled_vocabulary' => "name",
            'field_type' => "controlled_term",
            'is_facetable' => true,
            'is_identifier_searchable' => false,
            'is_keyword_searchable' => false,
            'is_title_searchable' => false,
            'select_options' => nil,
            'type' => "DynamicField"
          }
        ]
      end

      it 'returns complete list of fields map' do
        expect(all_fields).to match_array expected_fields
      end
    end
  end
end
