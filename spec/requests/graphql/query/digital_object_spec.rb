# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieving Digital Object', type: :request do
  include_context 'with stubbed search adapters'
  let(:authorized_object) do
    FactoryBot.create(:item, :with_rights, :with_ascii_title, :with_other_projects)
  end
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
          "title": {
            "nonSortPortion": "The",
            "sortPortion": "Best Item Ever",
            "subtitle": null,
            "lang": null
          },
          "numberOfChildren": 0,
          "createdAt": "#{authorized_object.created_at.iso8601}",
          "createdBy": null,
          "digitalObjectType": "ITEM",
          "displayTitle": "The Best Item Ever",
          "doi": #{authorized_object.doi.nil? ? 'null' : '"#{authorized_object.doi}"'},
          "descriptiveMetadata": {},
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
          "state": "ACTIVE",
          "updatedAt": "#{authorized_object.updated_at.iso8601}",
          "updatedBy": null
        }
      )).at_path('data/digitalObject')
    end
    context 'with utf8 descriptive metadata values' do
      let(:authorized_object) do
        FactoryBot.create(:item, :with_rights, :with_utf8_title, :with_utf8_dynamic_field_data, :with_other_projects)
      end
      let(:json_data) { JSON.parse(response.body) }
      let(:actual_title) { json_data&.dig('data', 'digitalObject', 'title', 'sortPortion') }
      let(:actual_alternate_title) { json_data&.dig('data', 'digitalObject', 'descriptiveMetadata', 'alternate_title', 0, 'value') }
      # expected value ends in Cora\u00e7\u00e3o (67, 111, 114, 97, 231, 227, 111)
      let(:expected_title_value) { [80, 97, 114, 97, 32, 77, 97, 99, 104, 117, 99, 97, 114, 32, 77, 101, 117, 32, 67, 111, 114, 97, 231, 227, 111] }
      let(:expected_alternate_title_value) { [83, 243, 32, 68, 97, 110, 231, 111, 32, 83, 97, 109, 98, 97] }
      it "preserves utf-8 data" do
        expect(actual_title&.unpack('U*')).to eql(expected_title_value)
        expect(actual_alternate_title&.unpack('U*')).to eql(expected_alternate_title_value)
      end
    end
  end

  context "missing title field" do
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      authorized_object.title.clear
      authorized_object.save
      graphql query(authorized_object.uid)
    end

    it "return a placeholder no-title value" do
      expect(response.body).to be_json_eql(%(
        "[No Title]"
      )).at_path('data/digitalObject/displayTitle')
    end
  end

  context "resources response" do
    let(:authorized_object) { FactoryBot.create(:asset, :with_main_resource) }
    let(:authorized_project) { authorized_object.projects.first }
    before do
      sign_in_project_contributor to: :read_objects, project: authorized_project
      graphql query(authorized_object.uid)
    end
    let(:expected_location) { Rails.root.join('spec', 'fixtures', 'files', 'test.txt').to_s }

    it "returns the expected resources response" do
      expect(response.body).to be_json_eql(%(
        [
          {
            "id": "main",
            "displayLabel": "Main",
            "resource": {
              "checksum": "sha256:717f2c6ffbd649cd57ecc41ac6130c3b6210f1473303bcd9101a9014551bffb2",
              "fileSize": 23,
              "location": "tracked-disk://#{expected_location}",
              "mediaType": "text/plain",
              "originalFilePath": "#{expected_location}",
              "originalFilename": "test.txt"
            }
          },
          {
            "id": "service",
            "displayLabel": "Service",
            "resource": null
          },
          {
            "id": "access",
            "displayLabel": "Access",
            "resource": null
          },
          {
            "id": "poster",
            "displayLabel": "Poster",
            "resource": null
          },
          {
            "id": "synchronized_transcript",
            "displayLabel": "Synchronized Transcript",
            "resource": null
          },
          {
            "id": "chapters",
            "displayLabel": "Chapters",
            "resource": null
          },
          {
            "id": "captions",
            "displayLabel": "Captions",
            "resource": null
          },
          {
            "id": "fulltext",
            "displayLabel": "Fulltext",
            "resource": null
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
          displayTitle
          title {
            nonSortPortion
            sortPortion
            subtitle
            lang
          }
          numberOfChildren
          descriptiveMetadata
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
            citationLocation
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
            resource {
              location
              checksum
              originalFilePath
              originalFilename
              mediaType
              fileSize
            }
          }
        }
      }
    GQL
  end
end
