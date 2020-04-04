# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Digital Object', type: :request do
  before { Hyacinth::DynamicFieldsLoader.load_rights_fields! }

  let(:authorized_object) { FactoryBot.create(:item, :with_rights, :with_primary_project, :with_other_projects) }
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

    it "return a single digital object with expected fields" do
      expect(response.body).to be_json_eql(%(
        {
          "id": "#{authorized_object.uid}",
          "title": "The Best Item Ever",
          "numberOfChildren": 0,
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
          "primaryProject": {
            "displayLabel": "Great Project",
            "projectUrl": "https://example.com/great_project",
            "stringKey": "great_project",
            "hasAssetRights": false
          },
          "otherProjects" : [
            {
              "displayLabel": "Other Project A",
              "projectUrl": "https://example.com/other_project_a",
              "stringKey": "other_project_a"
            },
            {
              "displayLabel": "Other Project B",
              "projectUrl": "https://example.com/other_project_b",
              "stringKey": "other_project_b"
            }
          ],
          "publishEntries": [],
          "rights": {
            "descriptive_metadata": [
              {
                "type_of_content": "literary"
              }
            ]
          },
          "resources" : [],
          "serializationVersion": "1",
          "state": "active",
          "updatedAt": "#{authorized_object.updated_at}",
          "updatedBy": null
        }
      )).at_path('data/digitalObject')
    end
  end

  context "missing title field" do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      authorized_object.dynamic_field_data.delete('title')
      authorized_object.save
      graphql query(authorized_object.uid)
    end

    it "return a placeholder no-title value" do
      expect(response.body).to be_json_eql(%(
        "[No Title]"
      )).at_path('data/digitalObject/title')
    end
  end

  context "resources response" do
    let(:authorized_object) { FactoryBot.create(:asset, :with_primary_project, :with_master_resource) }
    let(:authorized_project) { authorized_object.projects.first }
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql query(authorized_object.uid)
    end

    it "returns the expected resources response" do
      expect(response.body).to be_json_eql(%(
        [
          {
            "id": "master",
            "checksum": "SHA256:e1266b81a70083fa5e3bf456239a1160fc6ebc179cdd71e458a9dd4bc7cc21f6",
            "displayLabel": "Master",
            "fileSize": 23,
            "location": "managed-disk://#{Rails.root.join('spec', 'fixtures', 'files', 'test.txt')}",
            "mediaType": "text/plain",
            "originalFilename": "test.txt"
          },
          {
            "id": "service",
            "checksum": null,
            "displayLabel": "Service",
            "fileSize": null,
            "location": null,
            "mediaType": null,
            "originalFilename": null
          },
          {
            "id": "access",
            "checksum": null,
            "displayLabel": "Access",
            "fileSize": null,
            "location": null,
            "mediaType": null,
            "originalFilename": null
          }
        ]
      )).at_path('data/digitalObject/resources')
    end
  end

  def query(id)
    <<~GQL
      query {
        digitalObject(id: "#{id}") {
          id
          title
          numberOfChildren
          serializationVersion
          dynamicFieldData
          doi
          state
          digitalObjectType
          identifiers
          primaryProject {
            stringKey
            displayLabel
            projectUrl
            hasAssetRights
          }
          otherProjects {
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
          rights
          resources {
            id
            displayLabel
            location
            checksum
            originalFilename
            mediaType
            fileSize
          }
        }
      }
    GQL
  end
end
