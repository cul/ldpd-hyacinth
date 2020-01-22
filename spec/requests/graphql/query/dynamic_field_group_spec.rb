# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Dynamic Field Group', type: :request do
  let!(:field_export_profile) { FactoryBot.create(:field_export_profile) }

  describe 'get a dynamic field group' do
    let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

  # include_examples 'requires user to have correct permissions' do
  #   let(:request) {  graphql query(dynamic_field_group.string_key)  }
  # end
    context 'when logged in user is an administrator' do
      before { sign_in_user as: :administrator }

      context 'when id is valid' do
        before { graphql query(dynamic_field_group.id) }
        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
            {
                "dynamicFieldGroup": {
                "parent": {
                  "type": "DynamicFieldCategory"
                },
                "children": [],
                "displayLabel": "Name",
                "isRepeatable": true,
                "sortOrder": 3,
                "stringKey": "name",
                "type": "DynamicFieldGroup",
                "exportRules": []
              }
            }
          )).at_path('data')
        end        
      end
      context 'when id is invalid' do
        before { graphql query('1234') }

        it 'returns correct response' do
          expect(response.body).to be_json_eql(%(
           "Couldn't find DynamicFieldGroup with 'id'=1234"
          )).at_path('errors/0/message')
        end
      end
    end      
  end
  def query(id)
    <<~GQL
      query {
        dynamicFieldGroup(id: "#{id}") {        
         parent{
            type: __typename          
          }
          children{
            type: __typename
            ... on DynamicFieldGroup {stringKey}
            ... on DynamicField {stringKey}
          }
          displayLabel
          isRepeatable
          sortOrder
          stringKey
          type: __typename
          exportRules
         }
      }
    GQL
  end
end
