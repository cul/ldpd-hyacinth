# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateDynamicField, type: :request do
  let(:dynamic_field) { FactoryBot.create(:dynamic_field) }
  let(:parent) { FactoryBot.create(:dynamic_field_group) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) do
      { input: { stringKey: 'term', displayLabel: 'Term', fieldType: 'controlled_term', controlledVocabulary: 'names',
                 sortOrder: 6, dynamicFieldGroupId: parent.id, isFacetable: true, isKeywordSearchable: true, isTitleSearchable: true, isIdentifierSearchable: true } }
    end
    let(:request) { graphql query, variables }
  end

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
        expect(response.body).to be_json_eql(%({ "dynamicField": { "controlledVocabulary": "names", "displayLabel": "Term", "fieldType": "controlled_term",
                                                  "filterLabel": null, "isFacetable": true, "isIdentifierSearchable": true, "isKeywordSearchable": true,
                                                  "isTitleSearchable": true, "selectOptions": null, "sortOrder": 6, "stringKey": "term", "type": "DynamicField" } })).at_path('data/createDynamicField')
      end
    end

    context 'when creating without a display_label' do
      let(:variables) do
        {
          input: {
            stringKey: 'term', fieldType: 'controlled_term', controlledVocabulary: 'names',
            sortOrder: 6, dynamicFieldGroupId: parent.id, isFacetable: true, isKeywordSearchable: true, isTitleSearchable: true,
            isIdentifierSearchable: true
          }
        }
      end
      before { graphql query, variables }
      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Variable input of type CreateDynamicFieldInput! was provided invalid value for displayLabel (Expected value to not be null)"
        )).at_path('errors/0/message')
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
