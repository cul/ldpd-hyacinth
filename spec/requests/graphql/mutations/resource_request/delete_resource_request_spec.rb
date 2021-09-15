# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ResourceRequest::DeleteResourceRequest, type: :request do
  let(:resource_request) { FactoryBot.create(:resource_request) }
  let(:id) { resource_request.id }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:variables) { { input: { id: resource_request.id } } }
    let(:request) { graphql query, variables }
  end

  context 'when logged in user is resource request manager' do
    before { sign_in_user as: :resource_request_manager }

    context 'when deleting a resource request that exists' do
      let(:variables) { { input: { id: resource_request.id } } }

      before { graphql query, variables }

      it 'deletes record from database' do
        expect(ResourceRequest.find_by(id: id)).to be nil
      end
    end

    context 'when deleting a resource request that doesn\'t exist' do
      let(:variables) { { input: { id: '999888999' } } }

      before { graphql query, variables }

      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
         "Couldn't find ResourceRequest with 'id'=999888999"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: DeleteResourceRequestInput!) {
        deleteResourceRequest(input: $input) {
          resourceRequest {
            id
          }
        }
      }
    GQL
  end
end
