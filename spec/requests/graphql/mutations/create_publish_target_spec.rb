# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreatePublishTarget, type: :request do
  let(:string_key) { 'new_publish_target' }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) do
      {
        input: {
          stringKey: string_key,
          publishUrl: 'https://example.com',
          apiKey: 'something'
        }
      }
    end
    let(:request) { graphql query, variables }
  end

  context 'when logged in user has correct permissions' do
    before { sign_in_user as: :administrator }

    context 'when creating a new publish target' do
      let(:variables) do
        {
          input: {
            stringKey: string_key,
            publishUrl: 'https://bestproject/publish',
            apiKey: 'bestprojectapikey',
            isAllowedDoiTarget: true,
            doiPriority: 4
          }
        }
      end

      before { graphql query, variables }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "publishTarget": {
            "stringKey": "#{string_key}",
            "publishUrl": "https://bestproject/publish",
            "apiKey": "bestprojectapikey",
            "doiPriority": 4,
            "isAllowedDoiTarget": true
          }
        })).at_path('data/createPublishTarget')
      end
    end

    context 'when create request is missing stringKey' do
      let(:variables) do
        {
          input: {
            publishUrl: 'https://bestproject/publish',
            apiKey: 'bestprojectapikey'
          }
        }
      end

      before { graphql query, variables }

      it 'returns error' do
        expect(response.body).to be_json_eql(%(
          "Variable input of type CreatePublishTargetInput! was provided invalid value for stringKey (Expected value to not be null)"
        )).at_path('errors/0/message')
      end
    end
  end

  def query
    <<~GQL
      mutation ($input: CreatePublishTargetInput!) {
        createPublishTarget(input: $input) {
          publishTarget {
            stringKey
            publishUrl
            apiKey
            doiPriority
            isAllowedDoiTarget
          }
        }
      }
    GQL
  end
end
