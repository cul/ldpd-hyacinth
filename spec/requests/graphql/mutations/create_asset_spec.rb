# frozen_string_literal: true

require 'rails_helper'
require 'digest'

RSpec.describe Mutations::CreateAsset, type: :request do
  include_context 'with stubbed search adapters'

  let(:authorized_object) { FactoryBot.create(:item) }
  let(:authorized_project) { authorized_object.projects.first }

  let(:blob_content) { "This is text to store in a blob" }
  let(:blob_checksum) { Digest::MD5.base64digest blob_content }
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
  let(:file_location) { "blob://#{active_storage_blob.signed_id}" }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { parentId: authorized_object.uid, fileLocation: 'not-relevant' } } }
    let(:request) { graphql query, variables }
  end

  context "when logged in user does not have permission to create the asset" do
    before do
      sign_in_user # user without any permissions granted
      graphql query, variables
    end

    let(:variables) { { input: { parentId: authorized_object.uid, fileLocation: file_location } } }

    it 'deletes an upload after failure' do
      expect(ActiveStorage::Blob.exists?(active_storage_blob.id)).to be false
    end
  end

  context "when logged in user is authorized to create objects in the parent object's project" do
    let(:variables) { { input: { parentId: authorized_object.uid, fileLocation: file_location } } }

    before do
      sign_in_project_contributor to: [:read_objects, :create_objects], project: authorized_project
      graphql query, variables
    end

    context 'performing a ActiveStorage blob-based upload' do
      it 'returns a new asset' do
        expect(response.body).to have_json_type(String).at_path('data/createAsset/asset/id')
        expect(response.body).to be_json_eql("\"IMAGE\"").at_path('data/createAsset/asset/assetType')
        expect(response.body).to be_json_eql("\"blob.tiff\"").at_path('data/createAsset/asset/displayTitle')
      end
      it 'deletes the upload after success' do
        expect(ActiveStorage::Blob.exists?(active_storage_blob.id)).to be false
      end
    end

    context 'performing an upload type that is NOT ActiveStorage blob-based (which is only allowed for admins)' do
      let(:file_location) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt') }

      before { graphql query, variables }

      it 'fails due to lack of permissions' do
        expect(response.body).to be_json_eql("\"You are only authorized to create assets from ActiveStorage blob uploads.\"").at_path('errors/0/message')
      end
    end
  end

  context 'when an administrator tries to create an asset from a disk file location' do
    let(:file_location) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt') }
    let(:variables) { { input: { parentId: authorized_object.uid, fileLocation: file_location } } }

    before do
      sign_in_user as: :administrator
      graphql query, variables
    end

    it 'is successful' do
      expect(response.body).to have_json_type(String).at_path('data/createAsset/asset/id')
      expect(response.body).to be_json_eql("\"TEXT\"").at_path('data/createAsset/asset/assetType')
      expect(response.body).to be_json_eql("\"test.txt\"").at_path('data/createAsset/asset/displayTitle')
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateAssetInput!) {
        createAsset(input: $input) {
          asset {
            id
            assetType
            displayTitle
          }
        }
      }
    GQL
  end
end
