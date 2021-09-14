# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DigitalObject::PurgeDigitalObject, type: :request do
  include_context 'with stubbed search adapters'
  let(:item) { FactoryBot.create(:item) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query, input: { id: item.uid } }
  end

  context 'when logged in as regular user' do
    before { sign_in_user }
    context 'when purging a digital_object' do
      let(:id) { item.uid }
      before do
        graphql query, input: { id: id }
      end

      it 'returns authorization denied error' do
        expect(response.body).to be_json_eql(%(
          "You are not authorized to access this page."
          )).at_path('errors/0/message')
      end
    end
  end

  context 'when logged in user is an administrator' do
    before { sign_in_user as: :administrator }

    context 'when purging a digital_object that exists' do
      let(:id) { item.uid }
      before do
        graphql query, input: { id: id }
      end

      it 'returns purged object id' do
        expect(response.body).to be_json_eql(%("#{id}")).at_path('data/purgeDigitalObject/digitalObject/id')
      end
    end

    context 'when purging a digital_object that does not exist' do
      before do
        graphql query, input: { id: "invalid-key" }
      end
      it 'returns errors' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find DigitalObject"
          )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
    mutation ($input: PurgeDigitalObjectInput!) {
      purgeDigitalObject(input: $input) {
        digitalObject {
          id,
          state
        }
      }
    }
    GQL
  end
end
