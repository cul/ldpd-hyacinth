# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Dynamic Field', type: :request do
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query(dynamic_field.id) }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }
    context 'when stringKey is valid' do
      before { graphql query(dynamic_field.id) }
      let(:expected_json) do
        %(
          {
            "dynamicField":{
              "controlledVocabulary":"name_role",
              "displayLabel":"Value",
              "fieldType":"controlled_term",
              "filterLabel":"Name",
              "isFacetable":true,
              "isIdentifierSearchable":false,
              "isKeywordSearchable":false,
              "isTitleSearchable":false,
              "selectOptions":null,
              "sortOrder":7,
              "stringKey":"term",
              "type":"DynamicField",
              "path": "name/term",
              "ancestorNodes": [
                {
                  "displayLabel": "Descriptive Metadata",
                  "type": "DynamicFieldCategory"
                },
                {
                  "displayLabel": "Name",
                  "type": "DynamicFieldGroup"
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
      before { graphql query('not-valid') }
      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
           "Couldn't find DynamicField with 'id'=not-valid"
          )).at_path('errors/0/message')
      end
    end
  end
  def query(id)
    <<~GQL
    query {
      dynamicField(id: "#{id}") {
        type: __typename
        id
        stringKey
        displayLabel
        sortOrder
        fieldType
        isFacetable
        filterLabel
        selectOptions
        isKeywordSearchable
        isTitleSearchable
        isIdentifierSearchable
        controlledVocabulary
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
