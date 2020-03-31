# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchImport::CreateBatchImport, type: :request do
  context 'when creating a batch import' do
    let(:blob_content) { "id,field,field.other_field\n123,somedata,someotherdata" }
    let(:blob_checksum) { Digest::MD5.hexdigest blob_content }
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

    before { sign_in_user }

    context 'when updating record' do
      let(:variables) do
        {
          input: {
            priority: 'high',
            signedBlobId: active_storage_blob.signed_id
          }
        }
      end

      let(:expected_response) do
        %(
          {
            "priority": "high",
            "originalFilename": "blob.csv",
            "user": {
              "fullName": "Signed In User",
              "email": "logged-in-user@exaple.com"
            }
          }
        )
      end

      before { graphql query, variables }

      it 'returns expected response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/createBatchImport/batchImport').excluding('fileLocation')
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
          }
        }
      }
    GQL
  end
end
