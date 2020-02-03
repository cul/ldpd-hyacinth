# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Dynamic Field Categories', type: :request do

  context 'when logged in user is an admin shows all dynamic field categories' do
    describe 'when there are multiple results' do
      before do
        sign_in_user as: :administrator
      	FactoryBot.create(:dynamic_field_category)
      	FactoryBot.create(:dynamic_field_category, display_label: 'Location')
        graphql query
      end

      it 'returns all dynamic_field_categories' do
          expect(response.body).to be_json_eql(%(
            {
               "dynamicFieldCategories": [
                 {
                   "displayLabel": "Descriptive Metadata",
                   "children": [],
                   "sortOrder": 3
                 },
                 {
                   "displayLabel": "Location",
                   "children": [],
                   "sortOrder": 3
                 }
               ]
             }
           )).at_path('data')
      end

      it 'returns 200' do
        expect(response.status).to be 200
      end
    end
end
  def query
    <<~GQL
      query {
       dynamicFieldCategories {
        displayLabel
        children { id }
        sortOrder
      }
    }
    GQL
  end
end