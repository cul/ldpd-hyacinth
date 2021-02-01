# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Query for Term', type: :request, solr: true do
  let(:vocabulary) do
    FactoryBot.create(:vocabulary, custom_fields: {
      classification: { label: 'Classification', data_type: 'string' },
      harry_potter_reference: { label: 'Harry Potter Reference', data_type: 'boolean' }
    })
  end

  let(:term) do
    FactoryBot.create(
      :external_term,
      vocabulary: vocabulary,
      custom_fields: { 'classification': 'Horse' }
    )
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user }

    context 'when :uri valid' do
      before { graphql query(vocabulary.string_key, term.uri) }

      let(:expected_response) do
        %(
          {
            "term": {
              "uri": "http://id.worldcat.org/fast/1161301/",
              "prefLabel": "Unicorns",
              "altLabels": [],
              "authority": "fast",
              "termType": "EXTERNAL",
              "customFields": [
                { "field": "classification", "value": "Horse" },
                { "field": "harry_potter_reference", "value": null }
              ]
            }
          }
        )
      end

      it 'returns one term' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/vocabulary').excluding('uuid')
      end
    end

    context 'when :uri invalid' do
      before do
        graphql query(vocabulary.string_key, 'http://id.worldcat.org/fast/not_valid/')
      end

      it 'returns error in json' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find Term"
        )).at_path("errors/0/message")
      end
    end

    context 'when vocabulary doesn\'t exist' do
      before do
        graphql query('fantastic_beasts', 'http://id.worldcat.org/fast/not_valid/')
      end

      it 'returns error in json' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find Vocabulary"
        )).at_path('errors/0/message')
      end
    end

    context 'when term is part of a locked vocabulary' do
      let(:expected_response) do
        %(
          {
            "term": {
              "altLabels": [],
              "authority": "fast",
              "customFields": [
                {
                  "field": "classification",
                  "value": "Horse"
                },
                {
                  "field": "harry_potter_reference",
                  "value": null
                }
              ],
              "prefLabel": "Unicorns",
              "termType": "EXTERNAL",
              "uri": "http://id.worldcat.org/fast/1161301/"
            }
          }
        )
      end
      before do
        term
        vocabulary.update(locked: true)
        graphql query(vocabulary.string_key, term.uri)
      end

      it 'still returns the term, despite the vocabulary being locked' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/vocabulary')
      end
    end
  end

  def query(vocabulary, uri)
    <<~GQL
      query {
        vocabulary(stringKey: "#{vocabulary}") {
          term(uri: "#{uri}") {
            prefLabel
            uri
            altLabels
            authority
            termType
            customFields {
              field
              value
            }
          }
        }
      }
    GQL
  end
end
