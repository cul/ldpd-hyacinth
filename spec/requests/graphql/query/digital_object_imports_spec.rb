# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Digital Object Imports', type: :request do
  include_examples 'requires user to have correct permissions for graphql request' do
    let(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }
    let(:request) { graphql query, id: batch_import.id }
  end

  context 'when user with appropriate permissions logged in' do
    let(:batch_import) do
      sign_in_user
      FactoryBot.create(:batch_import, :with_digital_object_import, user: User.first)
    end

    before do
      FactoryBot.create(:digital_object_import, :success, batch_import: batch_import)
      FactoryBot.create(:digital_object_import, :in_progress, batch_import: batch_import)
      FactoryBot.create(:digital_object_import, :failure, batch_import: batch_import)
      FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import)
    end

    context "returns all digital object imports" do
      let(:expected_response) do
        %(
          {
            "batchImport": {
              "digitalObjectImports": {
                "nodes": [
                  {
                    "digitalObjectData": "{\\"descriptive_metadata\\":{\\"identifier\\":[{\\"value\\":\\"something_1\\"}]}}",
                    "importErrors": [],
                    "index": 19,
                    "status": "in_progress"
                  },
                  {
                    "digitalObjectData": "{\\"descriptive_metadata\\":{\\"note\\":[{\\"value\\":\\"fantastic note\\"}]}}",
                    "importErrors": [],
                    "index": 25,
                    "status": "pending"
                  },
                  {
                    "digitalObjectData": "{\\"digital_object_type\\":\\"item\\",\\"descriptive_metadata\\":{\\"title\\":[{\\"sort_portion\\":\\"The\\",\\"non_sort_portion\\":\\"Cool Item\\"}],\\"abstract\\":[{\\"abstract_value\\":\\"some abstract\\"}]}}",
                    "importErrors": [],
                    "index": 34,
                    "status": "pending"
                  },
                  {
                     "digitalObjectData": "{\\"descriptive_metadata\\":{\\"date\\":[{\\"value\\":\\"2001\\"}]}}",
                    "importErrors": [],
                    "index": 89,
                    "status": "success"
                  },
                  {
                    "digitalObjectData": "{\\"descriptive_metadata\\":{\\"location\\":[{\\"value\\":\\"some place\\"}]}}",
                    "importErrors": [
                      "location.value is not a valid field"
                    ],
                    "index": 99,
                    "status": "failure"
                  }
                ]
              }
            }
          }
        )
      end

      before { graphql query, id: batch_import.id }

      it "returns expected response" do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end

    context "returns in_progress digital object imports" do
      let(:expected_response) do
        %(
          {
            "batchImport": {
              "digitalObjectImports": {
                "nodes": [
                  {
                    "digitalObjectData": "{\\"descriptive_metadata\\":{\\"identifier\\":[{\\"value\\":\\"something_1\\"}]}}",
                    "importErrors": [],
                    "index": 19,
                    "status":  "in_progress"
                  }
                ]
              }
            }
          }
        )
      end

      before { graphql query, id: batch_import.id, status: 'in_progress' }

      it 'returns expected response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end
  end

  def query
    <<~GQL
      query BatchImport($id: ID!, $status: DigitalObjectImportStatusEnum) {
        batchImport(id: $id) {
          id
          digitalObjectImports(limit: 10, status: $status) {
            nodes {
              digitalObjectData
              importErrors
              status
              index
            }
          }
        }
      }
    GQL
  end
end
