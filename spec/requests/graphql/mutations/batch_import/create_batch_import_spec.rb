# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchImport::CreateBatchImport, type: :request do
  context 'when creating a batch import' do
    before { sign_in_user }

    context 'when updating record' do
      let(:variables) do
        {
          input: {
            priority: 'high'
          }
        }
      end

      let(:expected_response) do
        %(
          {
            "priority": "high",
            "fileLocation": null,
            "user": {
              "fullName": "Signed In User",
              "email": "logged-in-user@exaple.com"
            }
          }
        )
      end

      before { graphql query, variables }

      it 'returns expected response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/createBatchImport/batchImport')
      end

      it 'correctly adds a batch import' do
        expect(BatchImport.count).to be 1
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateBatchImportInput!) {
        createBatchImport(input: $input) {
          batchImport {
            id
            priority
            fileLocation
            user {
              fullName
              email
            }
          }
        }
      }
    GQL
  end
end
