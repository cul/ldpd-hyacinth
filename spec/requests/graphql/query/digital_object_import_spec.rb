# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Digital Object Import', type: :request do
  include_examples 'requires user to have correct permissions for graphql request' do
    let(:batch_import) { FactoryBot.create(:batch_import, :with_digital_object_import) }
    let(:request) { graphql query(batch_import.id, batch_import.digital_object_imports.first.id) }
  end

  context 'when user is logged in' do
    before { sign_in_user }

    context 'when id is valid' do
      let(:batch_import) { FactoryBot.create(:batch_import, user: User.first) }
      let(:digital_object_import) { FactoryBot.create(:digital_object_import, :pending, batch_import: batch_import) }

      let(:expected_response) do
        %(
          {
            "batchImport": {
              "digitalObjectImport": {
                "createdAt": "#{digital_object_import.created_at.strftime('%FT%TZ')}",
                "digitalObjectData": "{\\"descriptive_metadata\\":{\\"note\\":[{\\"value\\":\\"fantastic note\\"}]},\\"primary_project\\":{\\"string_key\\":\\"great_project\\"}}",
                "importErrors": [],
                "index": 25,
                "status": "pending",
                "updatedAt": "#{digital_object_import.created_at.strftime('%FT%TZ')}"
              }
            }
          }
        )
      end

      before { graphql query(batch_import.id, digital_object_import.id) }

      it 'returns digital object import' do
        expect(response.body).to be_json_eql(expected_response).at_path('data')
      end
    end

    context 'when id is invalid' do
      let(:batch_import) { FactoryBot.create(:batch_import, user: User.first) }
      before do
        graphql query(batch_import.id, '1345')
      end

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find DigitalObjectImport with 'id'=1345"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(batch_import_id, digital_object_import_id)
    <<~GQL
      query {
        batchImport(id: "#{batch_import_id}") {
          id
          digitalObjectImport(id: "#{digital_object_import_id}") {
            digitalObjectData
            importErrors
            status
            index
            createdAt
            updatedAt
          }
        }
      }
    GQL
  end
end
