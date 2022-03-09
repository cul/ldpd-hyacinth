# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchImport::StartBatchImport, type: :request do
  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: batch_import.id } } }
    let(:request) { graphql query, variables }
  end

  let(:batch_import) { FactoryBot.create(:batch_import) }

  let(:variables) do
    {
      input: {
        id: batch_import.id
      }
    }
  end

  context 'when batch_import belongs to logged in user' do
    before { sign_in batch_import.user }

    context 'when starting batch import' do
      before do
        expect(Resque).to receive(:enqueue).with(BatchImportStartJob, batch_import.id)
        graphql query, variables
      end

      it 'enqueues a BatchImportStartJob' do
        expect(response.body).to be_json_eql(%(
          {
            "id": "#{batch_import.id}"
          }
        )).at_path('data/startBatchImport/batchImport')
      end
    end
  end

  context 'when batch_import does not belong to logged in user' do
    before { sign_in_user }

    context 'when starting batch import' do
      before do
        expect(Resque).not_to receive(:enqueue)
        graphql query, variables
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "You are not authorized to access this page."
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: StartBatchImportInput!) {
        startBatchImport(input: $input) {
          batchImport {
            id
          }
        }
      }
    GQL
  end
end
