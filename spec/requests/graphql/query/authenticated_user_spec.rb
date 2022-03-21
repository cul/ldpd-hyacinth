# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Query for Authenticated User', type: :request do
  context 'when user without additional permissions is logged in' do
    before do
      sign_in_user
      graphql query
    end

    let(:expected_rules) do
      %(
        [
          {
            "actions": ["read", "update"],
            "conditions": {
              "id": #{User.first.id}
            },
            "inverted": false,
            "subject": ["User"]
          },
          {
            "actions": ["read", "update"],
            "conditions": {
              "uid": "#{User.first.uid}"
            },
            "inverted": false,
            "subject": ["User"]
          },
          {
            "actions": ["read", "create"],
            "conditions": {},
            "inverted": false,
            "subject": ["Term"]
          },
          {
            "actions": ["read"],
            "conditions": {},
            "inverted": false,
            "subject": ["PublishTarget"]
          },
          {
            "actions": ["read"],
            "conditions": {},
            "inverted": false,
            "subject": ["Vocabulary"]
          },
          {
            "actions": ["read"],
            "conditions": {},
            "inverted": false,
            "subject": ["DynamicFieldCategory"]
          },
          {
            "actions": ["create"],
            "conditions": {},
            "inverted": false,
            "subject": ["BatchExport"]
          },
          {
            "actions": ["read", "destroy"],
            "conditions": {
              "userId": #{User.first.id}
            },
            "inverted": false,
            "subject": ["BatchExport"]
          },
          {
            "actions": ["create"],
            "conditions": {},
            "inverted": false,
            "subject": ["BatchImport"]
          },
          {
            "actions": ["read", "update", "destroy"],
            "conditions": {
              "userId": #{User.first.id}
            },
            "inverted": false,
            "subject": ["BatchImport"]
          }
        ]
      )
    end

    it 'returns expected rules' do
      expect(response.body).to be_json_eql(expected_rules).at_path('data/authenticatedUser/rules').including('id')
    end
  end

  context 'when project user is logged in' do
    before do
      sign_in_project_contributor actions: [:read_objects, :update_objects, :assess_rights], projects: project
      graphql query
    end

    let(:project) { FactoryBot.create(:project) }
    let(:expected_rules) do
      %(
        [
          {
            "actions": ["read", "update"],
            "conditions": {
              "id": #{User.first.id}
            },
            "inverted": false,
            "subject": ["User"]
          },
          {
            "actions": ["read", "update"],
            "conditions": {
              "uid": "#{User.first.uid}"
            },
            "inverted": false,
            "subject": ["User"]
          },
          {
            "actions": ["read", "create"],
            "conditions": {},
            "inverted": false,
            "subject": ["Term"]
          },
          {
            "actions": ["read"],
            "conditions": {},
            "inverted": false,
            "subject": ["PublishTarget"]
          },
          {
            "actions": ["read"],
            "conditions": {},
            "inverted": false,
            "subject": ["Vocabulary"]
          },
          {
            "actions": ["read"],
            "conditions": {},
            "inverted": false,
            "subject": ["DynamicFieldCategory"]
          },
          {
            "actions": ["create"],
            "conditions": {},
            "inverted": false,
            "subject": ["BatchExport"]
          },
          {
            "actions": ["read", "destroy"],
            "conditions": {
              "userId": #{User.first.id}
            },
            "inverted": false,
            "subject": ["BatchExport"]
          },
          {
            "actions": ["create"],
            "conditions": {},
            "inverted": false,
            "subject": [
              "BatchImport"
            ]
          },
          {
            "actions": ["read", "update", "destroy"],
            "conditions": {
              "userId": #{User.first.id}
            },
            "inverted": false,
            "subject": ["BatchImport"]
          },
          {
            "actions": ["read"],
            "conditions": {
              "id": #{project.id}
            },
            "inverted": false,
            "subject": ["Project"]
          },
          {
            "actions": ["read"],
            "conditions": {
              "stringKey": "great_project"
            },
            "inverted": false,
            "subject": ["Project"]
          },
          {
            "actions": ["read"],
            "conditions": {
              "projectId": 1
            },
            "inverted": false,
            "subject": ["FieldSet"]
          },
          {
            "actions": ["read"],
            "conditions": {
              "project": {
                "stringKey": "great_project"
              }
            },
            "inverted": false,
            "subject": ["FieldSet"]
          },
          {
            "actions": ["read_objects"],
            "conditions": {
              "id": #{project.id}
            },
            "inverted": false,
            "subject": ["Project"]
          },
          {
            "actions": ["read_objects"],
            "conditions": {
              "stringKey": "great_project"
            },
            "inverted": false,
            "subject": ["Project"]
          },
          {
            "actions": ["update_objects"],
            "conditions": {
              "id": #{project.id}
            },
            "inverted": false,
            "subject": ["Project"]
          },
          {
            "actions": ["update_objects"],
            "conditions": {
              "stringKey": "great_project"
            },
            "inverted": false,
            "subject": ["Project"]
          },
          {
            "actions": ["assess_rights"],
            "conditions": {
              "id": #{project.id}
            },
            "inverted": false,
            "subject": ["Project"]
          },
          {
            "actions": ["assess_rights"],
            "conditions": {
              "stringKey": "great_project"
            },
            "inverted": false,
            "subject": ["Project"]
          }
        ]
      )
    end

    it 'returns expected rules' do
      expect(response.body).to be_json_eql(expected_rules).at_path('data/authenticatedUser/rules').including('id')
    end
  end

  def query
    <<~GQL
      query {
        authenticatedUser {
          email
          firstName
          lastName
          isActive
          isAdmin
          rules {
            actions
            subject
            conditions
            inverted
          }
        }
      }
    GQL
  end
end
