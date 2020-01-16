# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Query for vocabulary', type: :request do
  before { FactoryBot.create(:vocabulary) }

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user }

    context 'when stringKey is valid' do
      let(:expected_response) do
        %({
            "vocabulary": {
              "stringKey": "mythical_creatures",
              "label": "Mythical Creatures",
              "locked": false,
              "customFieldDefinitions": []
            }
          })
      end

      before { graphql query('mythical_creatures') }

      it 'returns one vocabulary' do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end

    context 'when stringKey is invalid' do
      before { graphql query('not_created_yet') }

      it 'returns error if vocabulary not found' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find Vocabulary"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(string_key)
    <<~GQL
      query {
        vocabulary(stringKey: "#{string_key}") {
          stringKey
          label
          locked
          customFieldDefinitions {
            fieldKey
            label
            dataType
          }
        }
      }
    GQL
  end
end
