# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Dynamic Field', type: :request do
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(dynamic_field.string_key) }
  end
  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }
    context 'when stringKey is valid' do
      before { graphql query(dynamic_field.string_key) }
      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({  "dynamicField": { "controlledVocabulary": "name_role", "displayLabel": "Value",
          "fieldType": "controlled_term", "filterLabel": "Name", "isFacetable": true, "isIdentifierSearchable": false, "isKeywordSearchable": false,
          "isTitleSearchable": false, "selectOptions": null,  "sortOrder": 7, "stringKey": "term", "type": "DynamicField" } }
          )).at_path('data')
      end
    end

    context 'when stringKey is invalid' do
      before { graphql query('not-valid') }
      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
           "Couldn't find DynamicField"
          )).at_path('errors/0/message')
      end
    end
  end
  def query(string_key)
    <<~GQL
    query {
      dynamicField(stringKey: "#{string_key}") {
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
      }
    }
    GQL
  end
end
