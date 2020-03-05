# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchImport::UpdateBatchImport, type: :request do
  let(:batch_import) { FactoryBot.create(:batch_import) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: batch_import.id } } }
    let(:request) { graphql query, variables }
  end

  context 'when batch_import belongs to logged in user' do
    context 'when updating record' do
      let(:variables) do
        {
          input: {
            id: batch_import.id,
            cancelled: true
          }
        }
      end

      before do
        sign_in batch_import.user
        graphql query, variables
      end

      it 'correctly updates batch import' do
        batch_import.reload
        expect(batch_import.cancelled).to be true
      end
    end
  end

  context 'when batch_import does not belong to logged in user' do
    let(:variables) do
      {
        input: {
          id: batch_import.id,
          cancelled: true
        }
      }
    end

    before do
      sign_in_user
      graphql query, variables
    end

    it 'does not update batch import' do
      batch_import.reload
      expect(batch_import.cancelled).to be false
    end

    it 'returns error' do
      expect(response.body).to be_json_eql(%(
        "You are not authorized to access this page."
      )).at_path('errors/0/message')
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateBatchImportInput!) {
        updateBatchImport(input: $input) {
          batchImport {
            id
          }
        }
      }
    GQL
  end
end
