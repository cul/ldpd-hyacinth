# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Project', type: :request do
  let(:project) { FactoryBot.create(:project, :with_enabled_dynamic_field, :with_publish_target) }

  include_examples 'a basic user with no abilities is not authorized to perform this request' do
    let(:request) { graphql query(project.string_key) }
  end

  context 'when logged in user has appropriate permissions' do
    before do
      sign_in_project_contributor actions: :read_objects, projects: project
      user = FactoryBot.create(:user, :basic)
      Permission.create(user: user, subject: 'Project', subject_id: project.id, action: 'read_objects')
      Permission.create(user: user, subject: 'Project', subject_id: project.id, action: 'create_objects')
      FactoryBot.create(:publish_target)
    end

    context 'when string_key is valid' do
      before { graphql query(project.string_key) }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%({
          "project": {
            "displayLabel": "Great Project",
            "hasAssetRights": false,
            "projectUrl": "https://example.com/great_project",
            "stringKey": "great_project",
            "projectPermissions": [
              {
                "actions": [
                  "read_objects"
                ],
                "project": {
                  "displayLabel": "Great Project",
                  "stringKey": "great_project"
                },
                "user": {
                  "fullName": "Signed In User"
                }
              },
              {
                "actions": [
                  "read_objects",
                  "create_objects"
                ],
                "project": {
                  "displayLabel": "Great Project",
                  "stringKey": "great_project"
                },
                "user": {
                  "fullName": "Basic User"
                }
              }
            ],
            "enabledDigitalObjectTypes" : [
              "item"
            ],
            "availablePublishTargets" : [
              {
                "enabled": true,
                "stringKey": "great_publish_target"
              },
              {
                "enabled": false,
                "stringKey": "great_publish_target_2"
              }
            ]
          }
        })).at_path('data')
      end
    end

    context 'when string_key is invalid' do
      before { graphql query('test-string-key') }

      it 'returns correct response' do
        expect(response.body).to be_json_eql(%(
          "Couldn't find Project"
        )).at_path('errors/0/message')
      end
    end
  end

  def query(string_key)
    <<~GQL
      query {
        project(stringKey: "#{string_key}") {
          stringKey
          displayLabel
          projectUrl
          hasAssetRights
          projectPermissions {
            user {
              id,
              fullName
            },
            project {
              stringKey
              displayLabel
            },
            actions
          }
          enabledDigitalObjectTypes
          availablePublishTargets {
            stringKey
            enabled
          }
        }
      }
    GQL
  end
end
