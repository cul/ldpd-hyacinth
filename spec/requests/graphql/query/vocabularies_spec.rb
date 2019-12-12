# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Query for vocabularies', type: :request do
  before do
    FactoryBot.create(:vocabulary)
    FactoryBot.create(:vocabulary, string_key: 'names', label: 'Names')
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user }

    context 'when requesting all vocabularies' do
      let(:expected_response) do
        %({
          "vocabularies": [
            { "stringKey": "mythical_creatures", "label": "Mythical Creatures", "locked": false, "customFieldDefinitions": [] },
            { "stringKey": "names", "label": "Names", "locked": false, "customFieldDefinitions": [] }
          ]
        })
      end

      before { graphql query }

      it 'returns expected response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end

    context 'when reducing limit' do
      let(:expected_response) do
        %({
            "vocabularies": [
              { "stringKey": "animals", "label": "Animals", "locked": false, "customFieldDefinitions": [] },
              { "stringKey": "mythical_creatures", "label": "Mythical Creatures", "locked": false, "customFieldDefinitions": [] }
            ]
        })
      end

      before do
        FactoryBot.create(:vocabulary, string_key: 'animals', label: 'Animals')
        graphql query(limit: 2)
      end

      it 'returns expected response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end

    xit 'sets limit to max_limit value when value exceeds max_limit' do
      get_with_auth '/api/v1/vocabularies?offset=0&limit=501'
      expect(response.body).to be_json_eql(%(
        { "offset": 0, "limit": 500, "total_records": 2 }
      )).excluding('vocabularies')
    end
  end

  def query(limit: 20)
    <<~GQL
      query {
        vocabularies(limit: #{limit}) {
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
