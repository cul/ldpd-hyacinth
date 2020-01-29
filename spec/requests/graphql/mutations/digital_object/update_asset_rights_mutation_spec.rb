# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating Asset Rights', type: :request do
  let(:authorized_item) { FactoryBot.create(:item, :with_primary_project_asset_rights) }
  let(:authorized_project) { authorized_item.primary_project }
  let(:authorized_asset) { FactoryBot.create(:asset, parent: authorized_item) }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: authorized_asset.uid } } }
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    let(:variables) do
      {
        input: {
          id: authorized_asset.uid,
          copyrightStatusOverride: [{
            copyrightStatement: {
              prefLabel: "In Copyright",
              termType: "external",
              uri: "https://example.com/term/in_copyright"
            },
            copyrightNotes: "No Copyright Notes",
            copyrightRegistered: false,
            copyrightRenewed: false,
            copyrightDateOfRenewal: "2001-01-01",
            copyrightExpirationDate: "2001-01-01",
            culCopyrightAssessmentDate: "2001-01-01"
          }],
          restrictionOnAccess: [{
            value: "Open",
            embargoRelease: "2001-01-01",
            location: [{
              term: {
                prefLabel: "Great Location",
                termType: "external",
                uri: "https://example.com/great_location"
              }
            }],
            affiliation: [
              { value: "something" }
            ],
            note: "restriction note"
          }]
        }
      }
    end

    let(:expected_rights) do
      variables[:input].except(:id).deep_transform_keys { |k| k.to_s.underscore }
    end

    let(:expected_response) do
      %(
        {
          "id": "#{authorized_asset.uid}",
          "rights": {
            "copyrightStatusOverride": [
              {
                "copyrightStatement": {
                  "prefLabel": "In Copyright",
                  "termType": "external",
                  "uri": "https://example.com/term/in_copyright"
                }
              }
            ]
          }
        }
      )
    end

    before do
      sign_in_project_contributor to: [:read_objects, :assess_rights], project: authorized_project
      graphql query, variables
    end

    it "return a asset with the expected rights fields" do
      expect(response.body).to be_json_eql(expected_response).at_path('data/updateAssetRights/asset')
    end

    it 'sets rights fields' do
      expect(DigitalObject::Base.find(authorized_asset.uid).rights).to match expected_rights
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateAssetRightsInput!) {
        updateAssetRights(input: $input) {
          asset {
            id
            rights {
              copyrightStatusOverride {
                copyrightStatement {
                  prefLabel
                  uri
                  termType
                }
              }
            }
          }
        }
      }
    GQL
  end
end
