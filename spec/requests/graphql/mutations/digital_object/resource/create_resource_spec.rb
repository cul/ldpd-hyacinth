# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::Resource::CreateResource, type: :request, solr: true do
  let(:authorized_object) { FactoryBot.create(:asset, :with_master_resource) }
  let(:authorized_project) { authorized_object.projects.first }

  let(:digital_object_uid) { authorized_object.uid }
  let(:resource_name) { 'access' }

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
  let(:blob_file_location) { "blob://#{active_storage_blob.signed_id}" }

  let(:disk_file_location) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt') }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: digital_object_uid, resourceName: 'does-not-matter', fileLocation: 'does-not-matter' } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has permission to create a resource' do
    before do
      sign_in_project_contributor to: [:read_objects, :update_objects], project: authorized_project
      graphql query, variables
    end

    let(:variables) { { input: { id: digital_object_uid, resourceName: resource_name, fileLocation: blob_file_location } } }

    context 'performing a ActiveStorage blob-based upload' do
      it 'returns a digital object with the new resource' do
        expect(response.body).to be_json_eql("\"access\"").at_path('data/createResource/digitalObject/resources/2/id')
        expect(response.body).to be_json_eql("\"blob.tiff\"").at_path('data/createResource/digitalObject/resources/2/resource/originalFilename')
      end
      it 'deletes the upload' do
        expect(ActiveStorage::Blob.exists?(active_storage_blob.id)).to be false
      end

      context 'when an invalid resourceName has been given' do
        let(:resource_name) { 'definitely-not-valid' }
        it 'fails with the expected error message' do
          expect(response.body).to be_json_eql("\"Resource type \\\"definitely-not-valid\\\" is not valid for assets\"").at_path('errors/0/message')
        end
      end

      context 'when a resource with the given resourceName already exists' do
        let(:authorized_object) { FactoryBot.create(:asset, :with_master_resource, :with_access_resource) }

        it 'fails with the expected error message' do
          expect(response.body).to be_json_eql(
            '"This asset already has a resource with name \\"access\\". If you want to replace the current \\"access\\" resource, delete it and then create a new one."'
          ).at_path('errors/0/message')
        end
      end
    end

    context 'performing an upload type that is NOT ActiveStorage blob-based (which is only allowed for admins)' do
      let(:variables) { { input: { id: digital_object_uid, resourceName: resource_name, fileLocation: disk_file_location } } }

      it 'fails due to lack of permissions' do
        expect(response.body).to be_json_eql("\"You are only authorized to create resources from ActiveStorage blob uploads.\"").at_path('errors/0/message')
      end
    end
  end

  context 'when an administrator tries to create a resource from a disk file location' do
    let(:variables) { { input: { id: digital_object_uid, resourceName: resource_name, fileLocation: blob_file_location } } }

    before do
      sign_in_user as: :administrator
      graphql query, variables
    end

    context 'performing an upload type that is NOT ActiveStorage blob-based' do
      let(:variables) { { input: { id: digital_object_uid, resourceName: resource_name, fileLocation: disk_file_location } } }

      it 'is successful' do
        expect(response.body).to be_json_eql("\"access\"").at_path('data/createResource/digitalObject/resources/2/id')
        expect(response.body).to be_json_eql("\"test.txt\"").at_path('data/createResource/digitalObject/resources/2/resource/originalFilename')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreateResourceInput!) {
        createResource(input: $input) {
          digitalObject {
            id
            resources {
              id
              resource {
                originalFilename
              }
            }
          }
          userErrors {
            message
          }
        }
      }
    GQL
  end
end
