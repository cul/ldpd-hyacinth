# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dynamic Field Categories Requests', type: :request do
  describe 'GET /api/v1/dynamic_field_categories' do
    before do
      FactoryBot.create(:dynamic_field_category)
      FactoryBot.create(:dynamic_field_category, display_label: 'Location')
    end

    context 'when logged in user' do
      before { sign_in_user }

      context 'when there are multiple results' do
        before do
          get '/api/v1/dynamic_field_categories'
        end

        it 'returns all dynamic_field_categories' do
          expect(response.body).to be_json_eql(%(
            {
               "dynamic_field_categories": [
                 {
                   "display_label": "Descriptive Metadata",
                   "children": [],
                   "sort_order": 3,
                   "type": "DynamicFieldCategory"
                 },
                 {
                   "display_label": "Location",
                   "children": [],
                   "sort_order": 3,
                   "type": "DynamicFieldCategory"
                 }
               ]
             }
           ))
        end

        it 'returns 200' do
          expect(response.status).to be 200
        end
      end
    end
  end
end
