# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Vocabulary::UpdateVocabulary, type: :request do
  before { FactoryBot.create(:vocabulary) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { stringKey: 'mythical_creatures', locked: true } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :vocabulary_manager }

    context 'when updating label' do
      let(:variables) { { input: { stringKey: 'mythical_creatures', label: 'FAST Mythical Creatures' } } }
      let(:expected_response) do
        %({
            "vocabulary": {
              "stringKey": "mythical_creatures",
              "label": "FAST Mythical Creatures",
              "locked": false,
              "customFieldDefinitions": []
            }
          })
      end

      before { graphql query, variables }

      it 'updates label for vocabulary' do
        expect(Vocabulary.find_by(string_key: 'mythical_creatures').label).to eql 'FAST Mythical Creatures'
      end

      it 'returns new vocabulary' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/updateVocabulary')
      end
    end

    context 'when invalid string key' do
      let(:variables) { { input: { stringKey: 'names', label: 'FAST Names' } } }

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find Vocabulary"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateVocabularyInput!) {
        updateVocabulary(input: $input) {
          vocabulary {
            stringKey
            label
            locked
            customFieldDefinitions {
              fieldKey
              dataType
              label
            }
          }
        }
      }
    GQL
  end
end
