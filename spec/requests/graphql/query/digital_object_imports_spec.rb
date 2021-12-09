# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Digital Object Imports', type: :request do
  include_examples 'a basic user with no abilities is not authorized to perform this request' do
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
      FactoryBot.create(:digital_object_import, :creation_failure, batch_import: batch_import)
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
                    "digitalObjectData": "{\\"descriptive_metadata\\":{\\"identifier\\":[{\\"value\\":\\"something_1\\"}]},\\"primary_project\\":{\\"string_key\\":\\"great_project_3\\"}}",
                    "importErrors": [],
                    "index": 19,
                    "status": "IN_PROGRESS"
                  },
                  {
                    "digitalObjectData": "{\\"descriptive_metadata\\":{\\"note\\":[{\\"value\\":\\"fantastic note\\"}]},\\"primary_project\\":{\\"string_key\\":\\"great_project_5\\"}}",
                    "importErrors": [],
                    "index": 25,
                    "status": "PENDING"
                  },
                  {
                    "digitalObjectData": "{\\"assign_uid\\":\\"2f4e2917-26f5-4d8f-968c-a4015b10e50f\\",\\"digital_object_type\\":\\"item\\",\\"descriptive_metadata\\":{\\"abstract\\":[{\\"value\\":\\"some abstract\\"}]},\\"primary_project\\":{\\"string_key\\":\\"great_project\\"},\\"title\\":{\\"value\\":{\\"sort_portion\\":\\"The\\",\\"non_sort_portion\\":\\"Cool Item\\"}}}",
                    "importErrors": [],
                    "index": 34,
                    "status": "PENDING"
                  },
                  {
                     "digitalObjectData": "{\\"descriptive_metadata\\":{\\"date\\":[{\\"value\\":\\"2001\\"}]},\\"primary_project\\":{\\"string_key\\":\\"great_project_2\\"}}",
                    "importErrors": [],
                    "index": 89,
                    "status": "SUCCESS"
                  },
                  {
                    "digitalObjectData": "{\\"descriptive_metadata\\":{\\"location\\":[{\\"value\\":\\"some place\\"}]},\\"primary_project\\":{\\"string_key\\":\\"great_project_4\\"}}",
                    "importErrors": [
                      "location.value is not a valid field"
                    ],
                    "index": 99,
                    "status": "CREATION_FAILURE"
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
                    "digitalObjectData": "{\\"descriptive_metadata\\":{\\"identifier\\":[{\\"value\\":\\"something_1\\"}]},\\"primary_project\\":{\\"string_key\\":\\"great_project_3\\"}}",
                    "importErrors": [],
                    "index": 19,
                    "status":  "IN_PROGRESS"
                  }
                ]
              }
            }
          }
        )
      end

      before { graphql query, id: batch_import.id, status: 'IN_PROGRESS' }

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
