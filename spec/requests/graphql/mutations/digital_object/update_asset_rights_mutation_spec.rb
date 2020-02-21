# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating Asset Rights', type: :request, solr: true do
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
            note: "No Copyright Notes",
            copyrightRegistered: 'yes',
            copyrightRenewed: 'yes',
            copyrightDateOfRenewal: "2001-01-01",
            copyrightExpirationDate: "2001-01-01",
            culCopyrightAssessmentDate: "2001-01-01"
          }],
          restrictionOnAccess: [{
            value: "Open",
            embargoReleaseDate: "2001-01-01",
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
          "prefLabel": "In Copyright",
          "uri": "https://example.com/term/in_copyright",
          "termType": "external"
        }
      )
    end

    before do
      sign_in_project_contributor to: [:read_objects, :assess_rights], project: authorized_project
      graphql query, variables
    end

    it "return a asset with the expected rights fields" do
      response_data = JSON.parse(response.body)
      copyright_statement = response_data['data']['updateAssetRights']['asset']['rights']['copyrightStatusOverride'][0]['copyrightStatement']
      expected_props = JSON.parse(expected_response)
      expect(copyright_statement).to include expected_props
    end

    it 'sets rights fields' do
      expect(DigitalObject::Base.find(authorized_asset.uid).rights).to include expected_rights
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateAssetRightsInput!) {
        updateAssetRights(input: $input) {
          asset {
            id
            rights {
              restrictionOnAccess {
                affiliation {
                  value
                }
                embargoReleaseDate
                location {
                  term {
                    prefLabel
                    uri
                    termType
                  }
                }
                note
                value
              }
              copyrightStatusOverride {
                copyrightDateOfRenewal
                copyrightExpirationDate
                note
                copyrightRegistered
                copyrightRenewed
                copyrightStatement {
                  prefLabel
                  uri
                  termType
                }
                culCopyrightAssessmentDate
              }
            }
          }
        }
      }
    GQL
  end
end
