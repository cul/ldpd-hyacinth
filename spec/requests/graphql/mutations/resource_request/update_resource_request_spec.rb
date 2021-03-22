# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ResourceRequest::UpdateResourceRequest, type: :request do
  let(:resource_request) { FactoryBot.create(:resource_request) }
  let(:status) { 'failure' }
  let(:processing_errors) { ['error1', 'error2', 'error3'] }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) do
      {
        input: {
          id: resource_request.id,
          status: status,
          processingErrors: processing_errors
        }
      }
    end
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is resource request manager' do
    before { sign_in_user as: :resource_request_manager }

    context 'when updating record' do
      let(:variables) do
        {
          input: {
            id: resource_request.id,
            status: status,
            processingErrors: processing_errors
          }
        }
      end
      before { graphql query, variables }

      it 'correctly updates record' do
        resource_request.reload
        expect(resource_request.status).to eql status
        expect(resource_request.processing_errors).to eql processing_errors
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateResourceRequestInput!) {
        updateResourceRequest(input: $input) {
          resourceRequest {
            id
            status
            processingErrors
          }
        }
      }
    GQL
  end
end
