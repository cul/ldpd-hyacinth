# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Term::CreateTerm, type: :request, solr: true do
  let(:vocabulary) do
    FactoryBot.create(:vocabulary, custom_fields: {
      classification: { label: 'Classification', data_type: 'string' },
      harry_potter_reference: { label: 'Harry Potter Reference', data_type: 'boolean' }
    })
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user }

    context 'when successfully creating a new external term' do
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            prefLabel: 'Minotaur (Greek mythological character)',
            uri: 'http://id.worldcat.org/fast/1023481',
            authority: 'fast',
            termType: 'external',
            customFields: [
              { field: "classification", value: "Human" }
            ]
          }
        }
      end
      let(:expected_response) do
        %({
            "term": {
              "prefLabel": "Minotaur (Greek mythological character)",
              "altLabels": [],
              "uri": "http://id.worldcat.org/fast/1023481",
              "authority": "fast",
              "termType": "external",
              "customFields": [
                { "field": "classification", "value": "Human" },
                { "field": "harry_potter_reference", "value": null}
              ]
            }
          })
      end

      before { graphql query, variables }

      it 'creates a term record' do
        expect(Term.count).to be 1
        expect(Term.first.uri).to eql 'http://id.worldcat.org/fast/1023481'
      end

      it 'returns newly created term in json' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/createTerm')
      end
    end

    context 'when successfully creating a new local term' do
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            prefLabel: 'Hippogriff',
            altLabels: ['Hippogryph'],
            termType: 'local',
            customFields: [
              { field: 'classification', value: 'Eagle' }
            ]
          }
        }
      end
      let(:expected_response) do
        %({
            "term": {
              "prefLabel": "Hippogriff",
              "altLabels": ["Hippogryph"],
              "termType": "local",
              "authority": null,
              "customFields": [
                { "field": "classification", "value": "Eagle" },
                { "field": "harry_potter_reference", "value": null }
              ]
            }
          })
      end

      before { graphql query, variables }

      it 'creates a term record' do
        expect(Term.count).to be 1
        expect(Term.first.uri).not_to be_blank
        expect(Term.first.alt_labels.first).to eql 'Hippogryph'
      end

      it 'returns newly created term in json' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/createTerm').excluding('uri')
      end
    end

    context 'when successfully creating a new temporary term' do
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            prefLabel: 'Hippogriff',
            termType: 'temporary'
          }
        }
      end

      let(:expected_json) do
        %({
            "term": {
              "prefLabel": "Hippogriff",
              "altLabels": [],
              "authority": null,
              "termType": "temporary",
              "customFields": [
                { "field": "classification", "value": null },
                { "field": "harry_potter_reference", "value": null }
              ]
            }
          })
      end

      before { graphql query, variables }

      it 'creates term record' do
        expect(Term.count).to be 1
        expect(Term.first.uri).to start_with('temp:')
        expect(Term.first.pref_label).to eql 'Hippogriff'
      end

      it 'return newly created term in json' do
        expect(response.body).to be_json_eql(expected_json).at_path('data/createTerm').excluding('uri')
      end
    end

    context 'when uri is missing for external term' do
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            prefLabel: 'Minotaur (Greek mythological character)',
            authority: 'fast',
            termType: 'external',
            customFields: [
              { field: 'harry_potter_reference', value: false }
            ]
          }
        }
      end

      before { graphql query, variables }

      it 'returns error in json' do
        expect(response.body).to be_json_eql(%(
          "Uri can't be blank; Uri hash can't be blank"
        )).at_path('errors/0/message')
      end
    end

    context 'when creating a external term that already exists' do
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            prefLabel: 'Unicorn',
            uri: 'http://id.worldcat.org/fast/1161301/',
            authority: 'fast',
            termType: 'external'
          }
        }
      end

      before do
        FactoryBot.create(:external_term, vocabulary: vocabulary)
        graphql query, variables
      end

      it 'returns error in json' do
        expect(response.body).to be_json_eql(%(
          "Uri hash unique check failed. This uri already exists in this vocabulary."
        )).at_path('errors/0/message')
      end
    end

    context 'when creating a temporary term that already exists' do
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            prefLabel: 'Yeti',
            termType: 'temporary'
          }
        }
      end
      before do
        FactoryBot.create(:temp_term, vocabulary: vocabulary)
        graphql query, variables
      end

      it 'returns error in json' do
        expect(response.body).to be_json_eql(%(
          "Uri hash unique check failed. This uri already exists in this vocabulary."
        )).at_path('errors/0/message')
      end
    end

    context 'when create a term on a locked vocabulary' do
      let(:variables) do
        {
          input: {
            vocabularyStringKey: vocabulary.string_key,
            prefLabel: 'Hippogriff',
            termType: 'temporary'
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
        )).at_path("errors/0/message")
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateTermInput!) {
        createTerm(input: $input) {
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
