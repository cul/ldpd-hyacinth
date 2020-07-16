# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Publish Targets', type: :request do
  let(:project) { FactoryBot.create(:project) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query }
  end

  context 'when logged in user has correct permissions' do
    before { sign_in_project_contributor to: :read_objects, project: project }

    describe 'when there are multiple results' do
      before do
        FactoryBot.create(:publish_target, project: project)
        FactoryBot.create(:publish_target, project: project, target_type: 'staging')
        graphql query
      end

      it 'returns all projects' do
        expect(response.body).to be_json_eql(%(
          {
            "project": {
              "stringKey": "great_project",
              "publishTargets": [
                {
                  "apiKey": "bestapikey",
                  "publishUrl": "https://www.example.com/publish",
                  "type": "PRODUCTION",
                  "doiPriority": 100,
                  "isAllowedDoiTarget": false
                },
                {
                  "apiKey": "bestapikey",
                  "publishUrl": "https://www.example.com/publish",
                  "type": "STAGING",
                  "doiPriority": 100,
                  "isAllowedDoiTarget": false
                }
              ]
            }
          }
        )).at_path('data')
      end
    end
  end

  def query
    <<~GQL
      query {
        project(stringKey: "#{project.string_key}") {
          stringKey
          publishTargets {
            apiKey
            publishUrl
            type
            doiPriority
            isAllowedDoiTarget
          }
        }
      }
    GQL
  end
end
