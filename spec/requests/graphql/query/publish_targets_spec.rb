# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Publish Targets', type: :request do
  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql projects_query }
  end

  context 'when logged in user is admin' do
    before { sign_in_user as: :administrator }

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
                "apiKey": "bestapikey",
                "publishUrl": "https://www.example.com/publish",
                "doiPriority": 100,
                "isAllowedDoiTarget": false
              },
              {
                "stringKey": "great_publish_target_2",
                "apiKey": "bestapikey",
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
