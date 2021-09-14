# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Dynamic Field Group', type: :request do
  let(:dynamic_field_group) { FactoryBot.create(:dynamic_field_group) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query(dynamic_field_group.id) }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when stringKey is valid' do
      before { graphql query(dynamic_field_group.id) }
      let(:expected_json) do
        %(
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
              "exportRules": [],
              "path": "name",
              "ancestorNodes": [
                {
                  "displayLabel": "Descriptive Metadata",
                  "type": "DynamicFieldCategory"
                }
              ]
            }
          }
        )
      end
      it 'returns correct response' do
        expect(response.body).to be_json_eql(expected_json).at_path('data')
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
          exportRules {
            translationLogic
            fieldExportProfile {
              id
            }
          }
          path
          ancestorNodes {
            ...on DynamicFieldGroup {
              id
              displayLabel
            }
            ...on DynamicFieldCategory {
              id
              displayLabel
            }
            type: __typename
          }
        }
      }
    GQL
  end
end
