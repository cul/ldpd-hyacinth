# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Term::DeleteTerm, type: :request do
  include_context 'with stubbed search adapters'
  let(:vocabulary) { term.vocabulary }
  let(:uri) { 'https://example.com/unicorns' }
  let(:term) { FactoryBot.create(:external_term, uri: uri) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { uri: term.uri, vocabularyStringKey: vocabulary.string_key } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has appropriate permissions' do
    before { sign_in_user as: :vocabulary_manager }

    context 'when deleting term' do
      let(:variables) { { input: { uri: uri, vocabularyStringKey: vocabulary.string_key } } }

      before { graphql query, variables }

      it 'removes term from database' do
        expect(Term.find_by(uri: uri)).to be nil
      end
    end

    context 'when attempting to delete a uri that is not associated with a known term' do
      let(:variables) do
        { input: { uri: "http://id.worldcat.org/fast/not_known/", vocabularyStringKey: vocabulary.string_key } }
      end

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find Term"
        )).at_path('errors/0/message')
      end
    end

    context 'when deleting a term on a locked vocabulary' do
      let(:variables) do
        { input: { uri: term.uri, vocabularyStringKey: vocabulary.string_key } }
      end

      before do
        vocabulary.update(locked: true)
        graphql query, variables
      end

      it 'returns error in json' do
        expect(response.body).to be_json_eql(%(
          "Vocabulary is locked"
        )).at_path("errors/0/message")
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteTermInput!) {
        deleteTerm(input: $input) {
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
