# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Vocabulary::CreateVocabulary, type: :request do
  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { stringKey: 'collections', label: 'Collections', locked: false } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :vocabulary_manager }

    context 'when successfully creating a new vocabulary' do
      let(:variables) do
        { input: { stringKey: 'collections', label: 'Collections', locked: true } }
      end
      let(:expected_response) do
        %({
            "vocabulary": {
              "stringKey": "collections",
              "label": "Collections",
              "locked": true,
              "customFieldDefinitions": []
            }
          })
      end

      before { graphql query, variables }

      it 'creates a new vocabulary record' do
        expect(Vocabulary.count).to be 1
        expect(Vocabulary.first.string_key).to eql 'collections'
      end

      it 'returns newly created vocabulary in json' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/createVocabulary')
      end
    end

    context 'when stringKey is missing' do
      let(:variables) do
        { input: { stringKey: nil, label: 'Collections' } }
      end

      before { graphql query, variables }

      it 'returns error in json' do
        expect(response.body).to be_json_eql(%(
          "Variable $input of type CreateVocabularyInput! was provided invalid value for stringKey (Expected value to not be null)"
        )).at_path('errors/0/message')
      end
    end

    context 'when creating a vocabulary that already exisits' do
      let(:variables) do
        { input: { stringKey: 'mythical_creatures', label: 'Mythical Creatures' } }
      end

      before do
        FactoryBot.create(:vocabulary)
        graphql query, variables
      end

      it 'returns error in json body' do
        expect(response.body).to be_json_eql(%(
          "String key has already been taken"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateVocabularyInput!) {
        createVocabulary(input: $input) {
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
