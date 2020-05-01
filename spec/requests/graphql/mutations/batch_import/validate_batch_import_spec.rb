# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::BatchImport::ValidateBatchImport, type: :request do
  context 'when submitting a blob for validation' do
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
          signedBlobId: active_storage_blob.signed_id
        }
      }
    end

    let(:expected_response) do
      %(
        {
          "isValid": true,
          "errors": []
        }
      )
    end

    context "successful creation" do
      before { graphql query, variables }

      it 'returns expected response' do
        expect(response.body).to be_json_eql(expected_response).at_path('data/validateBatchImport')
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
            "isValid": false,
            "errors": ["An error"]
          }
        )
      end

      it 'returns expected response' do
        expect(response.body).to be_json_eql(expected_validation_error_response).at_path('data/validateBatchImport')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: ValidateBatchImportInput!) {
        validateBatchImport(input: $input) {
          isValid
          errors
        }
      }
    GQL
  end
end
