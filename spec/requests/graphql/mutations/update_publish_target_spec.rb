# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdatePublishTarget, type: :request do
  let(:publish_target) { FactoryBot.create(:publish_target, string_key: 'cool_publish_target') }
  let(:string_key) { publish_target.string_key }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) do
      { input: { stringKey: string_key } }
    end
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has correct permissions' do
    before { sign_in_user as: :administrator }

    context 'when updating record' do
      let(:variables) do
        {
          input: {
            stringKey: string_key,
            apiKey: 'something-new',
            publishUrl: 'https://bestproject.com/publish'
          }
        }
      end

      before { graphql query, variables }

      it 'correctly updates record' do
        publish_target.reload
        expect(publish_target.api_key).to eql 'something-new'
        expect(publish_target.publish_url).to eql 'https://bestproject.com/publish'
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdatePublishTargetInput!) {
        updatePublishTarget(input: $input) {
          publishTarget {
            stringKey
          }
        }
      }
    GQL
  end
end
