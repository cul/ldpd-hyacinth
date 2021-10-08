# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::Resource::DeleteResource, type: :request do
  include_context 'with stubbed search adapters'
  let(:digital_object) { FactoryBot.create(:asset, :with_main_resource, :with_access_resource) }
  let(:project) { digital_object.projects.first }
  let(:resource_name) { 'access' }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: digital_object.uid, resourceName: 'does-not-matter' } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has permission to delete a resource' do
    before do
      sign_in_project_contributor actions: [:read_objects, :update_objects], projects: project
    end

    context 'success occurs' do
      let(:variables) { { input: { id: digital_object.uid, resourceName: resource_name } } }
      before do
        expect(digital_object.resources['access']).to be_present
        graphql query, variables
      end
      it 'when the resource previously existed' do
        expect(response.body).to be_json_eql("null").at_path('data/deleteResource/digitalObject/resources/2/resource')
      end
    end

    context 'failure occurs' do
      before { graphql query, variables }

      context 'when resource name is invalid' do
        let(:variables) { { input: { id: digital_object.uid, resourceName: 'definitely-not-valid' } } }
        it 'returns the expected error message' do
          expect(response.body).to be_json_eql("\"Resource type \\\"definitely-not-valid\\\" is not valid for assets\"").at_path('errors/0/message')
        end
      end

      context 'when resource name is valid, but no resource exists' do
        let(:variables) { { input: { id: digital_object.uid, resourceName: 'service' } } }
        it 'returns the expected error message' do
          expect(response.body).to be_json_eql("\"No \\\"service\\\" resource found for this asset\"").at_path('errors/0/message')
        end
      end

      context 'when resource is the main resource' do
        let(:resource_name) { digital_object.main_resource_name }
        let(:variables) { { input: { id: digital_object.uid, resourceName: resource_name } } }
        it 'returns the expected error message' do
          expect(response.body).to be_json_eql("\"Cannot delete the #{resource_name} resource for an asset. Create a new asset instead.\"").at_path('errors/0/message')
        end
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteResourceInput!) {
        deleteResource(input: $input) {
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
