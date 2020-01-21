# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Term::UpdateTerm, type: :request, solr: true do
  let(:vocabulary) do
    FactoryBot.create(:vocabulary, custom_fields: {
      classification: { label: 'Classification', data_type: 'string' },
      harry_potter_reference: { label: 'Harry Potter Reference', data_type: 'boolean' }
    })
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:term) { FactoryBot.create(:external_term, vocabulary: vocabulary) }
    let(:variables) { { input: { uri: term.uri, vocabularyStringKey: vocabulary.string_key } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :vocabulary_manager }

    context 'when updating alt_labels' do
      let(:term) do
        FactoryBot.create(:external_term,
                          vocabulary: vocabulary,
                          custom_fields: { 'classification' => 'Horses' })
      end
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            uri: term.uri,
            altLabels: ['Uni']
          }
        }
      end
      let(:expected_response) do
        %(
          {
            "term": {
              "uri": "http://id.worldcat.org/fast/1161301/",
              "prefLabel": "Unicorns",
              "altLabels": ["Uni"],
              "authority": "fast",
              "termType": "external",
              "customFields": [
                { "field": "classification", "value": "Horses" },
                { "field": "harry_potter_reference", "value": null }
              ]
            }
          }
        )
      end

      before { graphql query, variables }

      it 'updates alt_labels for term' do
        term.reload
        expect(term.alt_labels).to contain_exactly 'Uni'
      end

      it 'preserves custom fields' do
        term.reload
        expect(term.custom_fields).to match('classification' => 'Horses')
      end

      it 'returns updated term' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/updateTerm')
      end
    end

    context 'when adding multiple alt_labels' do
      let(:term) { FactoryBot.create(:external_term, vocabulary: vocabulary) }
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            uri: term.uri,
            altLabels: ['Uni', 'Horse with Horn']
          }
        }
      end
      let(:expected_response) do
        %(
          {
            "term": {
              "uri": "http://id.worldcat.org/fast/1161301/",
              "prefLabel": "Unicorns",
              "altLabels": ["Uni", "Horse with Horn"],
              "authority": "fast",
              "termType": "external",
              "customFields": [
                { "field": "classification", "value": null },
                { "field": "harry_potter_reference", "value": true }
              ]
            }
          }
        )
      end

      before { graphql query, variables }

      it 'adds alt_labels for term' do
        term.reload
        expect(term.alt_labels).to match_array ['Uni', 'Horse with Horn']
      end

      it 'returns updated term' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/updateTerm')
      end
    end

    context 'when trying to update custom fields' do
      let(:term) { FactoryBot.create(:external_term, vocabulary: vocabulary) }
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            uri: term.uri,
            customFields: [
              { field: "classification", value: "Horses" },
              { field: "harry_potter_reference", value: false }
            ]
          }
        }
      end
      let(:expected_response) do
        %(
          {
            "term": {
              "uri": "http://id.worldcat.org/fast/1161301/",
              "prefLabel": "Unicorns",
              "altLabels": [],
              "authority": "fast",
              "termType": "external",
              "customFields": [
                { "field": "classification", "value": "Horses" },
                { "field": "harry_potter_reference", "value": false }
              ]
            }
          }
        )
      end

      before { graphql query, variables }

      it 'returns updated term' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/updateTerm')
      end
    end

    context 'when attempting to update a uri that is not associated with a known term' do
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            uri: 'not/known',
            prefLabel: 'New Label'
          }
        }
      end

      before { graphql query, variables }

      it 'return error' do
        expect(response.body).to be_json_eql(%("Couldn't find Term")).at_path('errors/0/message')
      end
    end

    context 'when updating a term on a locked vocabulary' do
      let(:term) { FactoryBot.create(:external_term, vocabulary: vocabulary) }
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            uri: term.uri,
            altLabels: ['Uni']
          }
        }
      end

      before do
        vocabulary.update(locked: true)
        graphql query, variables
      end

      it 'returns error in json' do
        expect(response.body).to be_json_eql(%(
          "Vocabulary is locked."
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateTermInput!) {
        updateTerm(input: $input) {
          term {
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
