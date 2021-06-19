# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Publish Targets', type: :request do
  context 'when non-admin logged in user has correct permissions' do
    before { sign_in_user }

    describe 'when there are multiple results' do
      before do
        FactoryBot.create(:publish_target)
        FactoryBot.create(:publish_target)
        graphql query
      end

      it 'returns all projects' do
        expect(response.body).to be_json_eql(%(
          {
            "publishTargets": [
              {
                "stringKey": "great_publish_target",
                "apiKey": "#{Types::PublishTargetType::OBSCURED_API_KEY}",
                "publishUrl": "https://www.example.com/publish",
                "doiPriority": 100,
                "isAllowedDoiTarget": false
              },
              {
                "stringKey": "great_publish_target_2",
                "apiKey": "#{Types::PublishTargetType::OBSCURED_API_KEY}",
                "publishUrl": "https://www.example.com/publish",
                "doiPriority": 100,
                "isAllowedDoiTarget": false
              }
            ]
          }
        )).at_path('data')
      end
    end
  end

  def query
    <<~GQL
      query {
        publishTargets {
          stringKey
          apiKey
          publishUrl
          doiPriority
          isAllowedDoiTarget
        }
      }
    GQL
  end
end
