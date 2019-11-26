# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Field Set', type: :request do
  let(:authorized_object) { FactoryBot.create(:item, :with_project) }
  let(:authorized_project) { authorized_object.projects.first }
  let(:authorized_publish_target) { authorized_project.publish_targets.first }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:request) { graphql query(authorized_object.uid) }
  end

  context 'logged in' do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql query(authorized_object.uid)
    end

    it "return a single digital object with id" do
      expect(response.body).to be_json_eql(%(
        {
          "id": "#{authorized_object.uid}",
          "createdAt": "#{authorized_object.created_at}",
          "createdBy": null,
          "digitalObjectType": "item",
          "doi": "#{authorized_object.doi}",
          "dynamicFieldData": {
            "title": [
              {
                "non_sort_portion": "The",
                "sort_portion": "Best Item Ever"
              }
            ]
          },
          "firstPreservedAt": null,
          "firstPublishedAt": null,
          "identifiers": [
          ],
          "optimisticLockToken": "#{authorized_object.optimistic_lock_token}",
          "parents": [],
          "preservedAt": null,
          "projects": [
            {
              "displayLabel": "Great Project",
              "projectUrl": "https://example.com/great_project",
              "stringKey": "great_project"
            }
          ],
          "publishEntries": [],
          "serializationVersion": "1",
          "state": "active",
          "updatedAt": "#{authorized_object.updated_at}",
          "updatedBy": null
        }
      )).at_path('data/digitalObject')
    end
  end

  def query(id)
    <<~GQL
      query {
        digitalObject(id: "#{id}") {
          id
          serializationVersion
          dynamicFieldData
          doi
          state
          digitalObjectType
          identifiers
          projects {
            stringKey
            displayLabel
            projectUrl
          }
          createdAt
          createdBy {
            id
            firstName
            lastName
          }
          updatedAt
          updatedBy {
            id
            firstName
            lastName
          }
          firstPublishedAt
          firstPreservedAt
          preservedAt
          parents {
            id
          }
          publishEntries {
            citedAt
            publishedAt
            publishedBy {
              id
            }
          }
          optimisticLockToken
        }
      }
    GQL
  end
end
