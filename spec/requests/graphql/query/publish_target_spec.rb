# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Publish Targets', type: :request do
  let(:publish_target) { FactoryBot.create(:publish_target) }

  context 'when logged in user is admin' do
    before { sign_in_user as: :administrator }

    context 'when type is valid' do
      before do
        graphql query(publish_target.string_key)
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "publishTarget": {
            "stringKey": "#{publish_target.string_key}",
            "apiKey": "#{publish_target.api_key}",
            "publishUrl": "https://www.example.com/publish",
            "doiPriority": 100,
            "isAllowedDoiTarget": false
          }
        })).at_path('data')
      end
    end
  end

  context 'when logged in user is not an admin' do
    before { sign_in_user }

    context 'when string key is valid' do
      before do
        graphql query(publish_target.string_key)
      end

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "publishTarget": {
            "stringKey": "#{publish_target.string_key}",
            "apiKey": "#{Types::PublishTargetType::OBSCURED_API_KEY}",
            "publishUrl": "https://www.example.com/publish",
            "doiPriority": 100,
            "isAllowedDoiTarget": false
          }
        })).at_path('data')
      end
    end

    context 'when string key is invalid' do
      before { graphql query('not_valid') }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find PublishTarget"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(string_key)
    <<~GQL
      query {
        publishTarget(stringKey: "#{string_key}") {
          stringKey
          publishUrl
          doiPriority
          isAllowedDoiTarget
          apiKey
        }
      }
    GQL
  end
end
