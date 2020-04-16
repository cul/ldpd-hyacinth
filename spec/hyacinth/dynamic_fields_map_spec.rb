# frozen_string_literal: true

require 'rails_helper'

describe Hyacinth::DynamicFieldsMap do
  describe '.generate' do
    context 'when there aren\'t any categories present' do
      subject(:map) { described_class.generate('item_rights') }

      it 'returns empty map' do
        expect(map).to eql({})
      end
    end

    context 'when generating map for asset_rights form' do
      subject(:map) { described_class.generate('asset_rights') }
      before { Hyacinth::DynamicFieldsLoader.load_rights_fields! }

      let(:expected_map) do
        {
          "copyright_status_override" => {
            "type" => "DynamicFieldGroup",
            "children" => {
              "copyright_date_of_renewal" => {
                'controlled_vocabulary' => nil,
                'field_type' => 'date',
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              },
              'copyright_expiration_date' => {
                'controlled_vocabulary' => nil,
                'field_type' => "date",
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              },
              "copyright_registered" => {
                'controlled_vocabulary' => nil,
                'field_type' => "select",
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => "[\n  { \"label\": \"Yes\", \"value\": \"yes\" },\n  { \"label\": \"No\", \"value\": \"no\" }\n]\n",
                'type' => "DynamicField"
              },
              "copyright_renewed" => {
                'controlled_vocabulary' => nil,
                'field_type' => "select",
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => "[\n  { \"label\": \"Yes\", \"value\": \"yes\" },\n  { \"label\": \"No\", \"value\": \"no\" }\n]\n",
                'type' => "DynamicField"
              },
              "copyright_statement" => {
                'controlled_vocabulary' => "rights_statement",
                'field_type' => "controlled_term",
                'is_facetable' => true,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              },
              "cul_copyright_assessment_date" => {
                'controlled_vocabulary' => nil,
                'field_type' => "date",
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              },
              "note" => {
                'controlled_vocabulary' => nil,
                'field_type' => "textarea",
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => true,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              }
            }
          },
          "restriction_on_access" => {
            "type" => "DynamicFieldGroup",
            "children" => {
              "affiliation" => {
                "type" => "DynamicFieldGroup",
                "children" => {
                  "value" => {
                    'controlled_vocabulary' => nil,
                    'field_type' => "string",
                    'is_facetable' => false,
                    'is_identifier_searchable' => false,
                    'is_keyword_searchable' => false,
                    'is_title_searchable' => false,
                    'select_options' => nil,
                    'type' => "DynamicField"
                  }
                }
              },
              "embargo_release_date" => {
                'controlled_vocabulary' => nil,
                'field_type' => "date",
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              },
              "location" => {
                "type" => "DynamicFieldGroup",
                "children" => {
                  "term" => {
                    'controlled_vocabulary' => "location",
                    'field_type' => "controlled_term",
                    'is_facetable' => false,
                    'is_identifier_searchable' => false,
                    'is_keyword_searchable' => false,
                    'is_title_searchable' => false,
                    'select_options' => nil,
                    'type' => "DynamicField"
                  }
                }
              },
              "note" => {
                'controlled_vocabulary' => nil,
                'field_type' => "string",
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => true,
                'is_title_searchable' => false,
                'select_options' => nil,
                'type' => "DynamicField"
              },
              "value" => {
                'controlled_vocabulary' => nil,
                'field_type' => "select",
                'is_facetable' => false,
                'is_identifier_searchable' => false,
                'is_keyword_searchable' => false,
                'is_title_searchable' => false,
                'select_options' => "[\n  { \"value\": \"Public Access\", \"label\": \"Public Access\" },\n  { \"value\": \"On-site Access\", \"label\": \"On-site Access\" },\n  { \"value\": \"Specified Group/UNI Access\", \"label\": \"Specified Group/UNI Access\" },\n  { \"value\": \"Closed\", \"label\": \"Closed\" },\n  { \"value\": \"Embargoed\", \"label\": \"Embargoed\" }\n]\n",
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
