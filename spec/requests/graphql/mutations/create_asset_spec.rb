# frozen_string_literal: true

require 'rails_helper'
require 'digest'

RSpec.describe Mutations::CreateAsset, type: :request do
  let(:authorized_object) { FactoryBot.create(:item, :with_primary_project) }
  let(:authorized_project) { authorized_object.projects.first }
  let(:blob_content) { "This is text to store in a blob" }
  let(:blob_checksum) { Digest::MD5.hexdigest blob_content }
  let(:blob_args) do
    {
      filename: 'blob.tiff',
      byte_size: blob_content.bytesize,
      checksum: blob_checksum,
      content_type: 'image/tiff'
    }
  end
  let(:active_storage_blob) do
    blob = ActiveStorage::Blob.create_before_direct_upload!(**blob_args)
    blob.upload(StringIO.new(blob_content))
    blob
  end

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) do
      {
        input: {
          parentId: authorized_object.uid, signedBlobId: 'not-relevant'
        }
      }
    end
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when adding asset from an upload' do
      let(:variables) do
        {
          input: {
            parentId: authorized_object.uid, signedBlobId: active_storage_blob.signed_id
          }
        }
      end

      before { graphql query, variables }

      it 'returns a new asset' do
        expect(response.body).to have_json_type(String).at_path('data/createAsset/asset/id')
        expect(response.body).to be_json_eql("\"Image\"").at_path('data/createAsset/asset/assetType')
      end
      it 'deletes the upload' do
        expect(ActiveStorage::Blob.exists?(active_storage_blob.id)).to be false
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateAssetInput!) {
        createAsset(input: $input) {
          asset {
            id
            assetType
          }
        }
      }
    GQL
  end
end
