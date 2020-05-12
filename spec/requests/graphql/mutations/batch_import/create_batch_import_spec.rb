# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchImport::CreateBatchImport, type: :request do
  context 'when creating a batch import' do
    before { sign_in_user }

    let(:blob_content) { "_uid,_field,field[0].other_field\n123,somedata,someotherdata" }
    let(:blob_checksum) { Digest::MD5.base64digest blob_content }
    let(:blob_args) do
      {
        filename: 'blob.csv',
        byte_size: blob_content.bytesize,
        checksum: blob_checksum,
        content_type: 'text/csv'
      }
    end
    let(:active_storage_blob) do
      blob = ActiveStorage::Blob.create_before_direct_upload!(**blob_args)
      blob.upload(StringIO.new(blob_content))
      blob
    end

    let(:variables) do
      {
        input: {
          priority: 'high',
          signedBlobId: active_storage_blob.signed_id
        }
      }
    end

    let(:response_hash) { JSON.parse(response.body)['data']['createBatchImport'] }

    let(:expected_response) do
      %(
        {
          "batchImport": {
            "priority": "high",
            "originalFilename": "blob.csv",
            "user": {
              "fullName": "Signed In User",
              "email": "logged-in-user@exaple.com"
            },
            "setupErrors": []
          },
          "isValid": true,
          "errors": []
        }
      )
    end

    let(:expected_response_hash) { JSON.parse(expected_response) }

    context "successful creation" do
      before { graphql query, variables }

      it 'returns expected response' do
        expected_response_hash['fileLocation'] = response_hash['batchImport']['fileLocation']
        expect(response_hash).to eq(response_hash)
      end

      it 'correctly adds a batch import' do
        expect(BatchImport.count).to be 1
      end

      it 'adds file' do
        file_location = JSON.parse(response.body)['data']['createBatchImport']['batchImport']['fileLocation']
        expect(Hyacinth::Config.batch_import_storage.read(file_location)).to eql blob_content
      end

      it 'deletes the upload' do
        expect(ActiveStorage::Blob.exists?(active_storage_blob.id)).to be false
      end
    end

    context 'with validation errors' do
      before do
        allow(BatchImport).to receive(:pre_validate_blob).and_return([false, ['An error']])
        graphql query, variables
      end

      let(:expected_validation_error_response) do
        %(
          {
            "batchImport": null,
            "isValid": false,
            "errors": ["An error"]
          }
        )
      end

      it 'returns expected response' do
        expect(response.body).to be_json_eql(expected_validation_error_response).at_path('data/createBatchImport')
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
            originalFilename
            user {
              fullName
              email
            }
            setupErrors
          }
          isValid
          errors
        }
      }
    GQL
  end
end
