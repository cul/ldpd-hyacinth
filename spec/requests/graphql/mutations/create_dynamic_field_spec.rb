# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateDynamicField, type: :request do
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }
  let(:parent) { FactoryBot.create(:dynamic_field_group) }


  describe '.resolve' do

    context 'when logged in user has appropriate permissions' do
    let(:variables) do
      {
        input: {
              stringKey: 'term', displayLabel: 'Term', fieldType: 'controlled_term', controlledVocabulary: 'names',
              sortOrder: 6, dynamicFieldGroupId: parent.id, isFacetable: true, isKeywordSearchable: true, isTitleSearchable: true,
              isIdentifierSearchable: true
        }
      }
    end
      before { sign_in_user as: :administrator }

      context 'when creating a new field' do
        before { graphql query, variables }

        it 'returns correct response' do
           expect(response.body).to be_json_eql(%({
              "dynamicField": {
                "controlledVocabulary": "name_role",
                "displayLabel": "Value",
                "fieldType": "controlled_term",
                "filterLabel": "Name",
                "isFacetable": true,
                "isIdentifierSearchable": false,
                "isKeywordSearchable": false,
                "isTitleSearchable": false,
                "selectOptions": null,
                "sortOrder": 7,
                "stringKey": "term",
                "type": "DynamicField"
              }
          })).at_path('data/createDynamicField')
        end
    end
  end
    def query
      <<~GQL
        mutation ($input: CreateDynamicFieldInput!) {
          createDynamicField(input: $input) {
            dynamicField {
              controlledVocabulary,
              displayLabel,
              fieldType,
              filterLabel,
              isFacetable,
              isIdentifierSearchable,
              isKeywordSearchable,
              isTitleSearchable,
              selectOptions,
              sortOrder,
              stringKey,
              type: __typename,
            }
          }
        }
      GQL
    end
  end
end
