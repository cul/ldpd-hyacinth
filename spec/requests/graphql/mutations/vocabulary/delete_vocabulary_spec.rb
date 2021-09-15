# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Vocabulary::DeleteVocabulary, type: :request do
  let(:vocabulary) { FactoryBot.create(:vocabulary) }

  before { vocabulary }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { stringKey: 'mythical_creatures' } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :vocabulary_manager }

    context 'when deleting vocabulary' do
      let(:variables) { { input: { stringKey: vocabulary.string_key } } }

      before { graphql query, variables }

      it 'removes vocabulary from database' do
        expect(Vocabulary.find_by(string_key: vocabulary.string_key)).to be nil
      end
    end

    context 'when invalid string key' do
      let(:variables) { { input: { stringKey: 'names' } } }

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
      mutation ($input: DeleteVocabularyInput!) {
        deleteVocabulary(input: $input) {
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
