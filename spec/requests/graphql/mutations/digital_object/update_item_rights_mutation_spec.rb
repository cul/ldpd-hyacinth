# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating Item Rights', type: :request do
  let(:authorized_object) { FactoryBot.create(:item, :with_primary_project) }
  let(:authorized_project) { authorized_object.primary_project }

  include_examples 'requires user to have correct permissions for graphql request' do
    let(:variables) { { input: { id: authorized_object.uid } } }
    let(:request) { graphql query, variables }
  end

  context "when logged in user has appropriate permissions" do
    let(:variables) do
      {
        input: {
          id: authorized_object.uid,
          descriptiveMetadata: [{
            typeOfContent: "motion_picture",
            countryOfOrigin: {
              prefLabel: "United States",
              termType: "external",
              uri: "https://example.com/term/united_states"
            },
            filmDistributedToPublic: true,
            filmDistributedCommercially: true
          }],
          copyrightStatus: [{
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
          copyrightOwnership: [{
            name: {
              prefLabel: "Random, Person",
              termType: "external",
              uri: "https://example.com/term/random,person"
            },
            heirs: "No Heirs",
            contactInformation: "No Contact Information"
          }],
          columbiaUniversityIsCopyrightHolder: [{
            dateOfTransfer: "2001-01-01",
            dateOfExpiration: "2001-01-01",
            transferDocumentation: "None",
            otherTransferEvidence: "None",
            transferDocumentationNote: "No Notes"
          }],
          licensedToColumbiaUniversity: [{
            dateOfLicense: "2002-01-01",
            terminationDateOfLicense: "2002-02-02",
            credits: "No credits",
            acknowledgements: "No acknowledgements",
            licenseDocumentationLocation: "Unknown"
          }],
          contractualLimitationsRestrictionsAndPermissions: [{
            optionA: true,
            optionB: false,
            optionC: true,
            optionD: false,
            optionE: false,
            optionAvA: false,
            optionAvB: false,
            optionAvC: false,
            optionAvD: false,
            optionAvE: false,
            optionAvF: true,
            optionAvG: false,
            reproductionAndDistributionProhibitedUntil: "2010-01-01",
            photographicOrFilmCredit: "No Credits",
            excerptLimitedTo: "23 minutes",
            other: "None",
            permissionsGrantedAsPartOfTheUseLicense: [{ value: "No permissions" }]
          }],
          underlyingRights: [{
            note: "No underlying rights",
            talentRights: "No talent rights",
            columbiaMusicLicense: "Master recording license",
            composition: "none",
            recording: "none",
            otherUnderlyingRights: [{ value: "VARA rights" }],
            other: "no other"
          }]
        }
      }
    end

    let(:expected_rights) do
      variables[:input].except(:id).deep_transform_keys { |k| k.to_s.underscore }
    end

    before do
      sign_in_project_contributor to: [:read_objects, :assess_rights], project: authorized_project
      graphql query, variables
    end

    it "return a single item with the expected rights fields" do
      expect(response.body).to be_json_eql("\"motion_picture\"").at_path('data/updateItemRights/item/rights/descriptiveMetadata/0/typeOfContent')
    end

    it 'sets rights fields' do
      expect(DigitalObject::Base.find(authorized_object.uid).rights).to include expected_rights
    end
  end

  def query
    <<~GQL
      mutation ($input: UpdateItemRightsInput!) {
        updateItemRights(input: $input) {
          item {
            id
            rights
          }
        }
      }
    GQL
  end
end
