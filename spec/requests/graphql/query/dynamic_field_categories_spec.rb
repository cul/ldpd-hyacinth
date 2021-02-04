# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Dynamic Field Categories', type: :request do
  context 'when logged in user is an admin shows all dynamic field categories' do
    describe 'when there are multiple results' do
      before do
        sign_in_user as: :administrator
        FactoryBot.create(:dynamic_field_category)
        FactoryBot.create(:dynamic_field_category, display_label: 'Location')
        FactoryBot.create(:dynamic_field_category, display_label: 'Item Rights', metadata_form: :asset_rights)
        graphql query
      end

      let(:expected_response) do
        %(
          [
            { "displayLabel": "Descriptive Metadata", "children": [], "sortOrder": 3 },
            { "displayLabel": "Location", "children": [], "sortOrder": 3 },
            { "displayLabel": "Item Rights", "children": [], "sortOrder": 3 }
          ]
        )
      end

      it 'returns all dynamic_field_categories' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/dynamicFieldCategories')
      end
    end

    describe 'when filtering results' do
      before do
        sign_in_user as: :administrator
        FactoryBot.create(:dynamic_field_category)
        FactoryBot.create(:dynamic_field_category, display_label: 'Item Rights', metadata_form: :item_rights)
        FactoryBot.create(:dynamic_field_category, display_label: 'Asset Rights', metadata_form: :asset_rights)
        graphql query, metadataForm: "ITEM_RIGHTS"
      end

      it 'returns results that match the filter' do
        expect(response.body).to be_json_eql(%(
          [ { "displayLabel": "Item Rights", "children": [], "sortOrder": 3 } ]
        )).at_path('data/dynamicFieldCategories')
      end
    end
  end

  def query
    <<~GQL
      query DynamicFieldCategories($metadataForm: MetadataFormEnum){
        dynamicFieldCategories(metadataForm: $metadataForm) {
          displayLabel
          children { id }
          sortOrder
        }
      }
    GQL
  end
end
