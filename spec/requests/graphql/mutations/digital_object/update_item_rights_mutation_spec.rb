# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating Item Rights', type: :request, solr: true do
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
            filmDistributedToPublic: 'yes',
            filmDistributedCommercially: 'yes'
          }],
          copyrightStatus: [{
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
            optionB: true,
            optionC: true,
            optionD: true,
            optionE: true,
            optionAvA: true,
            optionAvB: true,
            optionAvC: true,
            optionAvD: true,
            optionAvE: true,
            optionAvF: true,
            optionAvG: true,
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
            rights {
              copyrightStatus {
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
              columbiaUniversityIsCopyrightHolder {
                dateOfExpiration
                dateOfTransfer
                otherTransferEvidence
                transferDocumentation
                transferDocumentationNote
              }
              contractualLimitationsRestrictionsAndPermissions {
                excerptLimitedTo
                optionA
                optionB
                optionC
                optionD
                optionE
                optionAvA
                optionAvB
                optionAvC
                optionAvD
                optionAvE
                optionAvF
                optionAvG
                other
                permissionsGrantedAsPartOfTheUseLicense {
                  value
                }
                photographicOrFilmCredit
                reproductionAndDistributionProhibitedUntil
              }
              copyrightOwnership {
                contactInformation
                heirs
                name {
                  termType
                  prefLabel
                  uri
                }
              }
              descriptiveMetadata {
                typeOfContent
                countryOfOrigin {
                  prefLabel
                  uri
                  termType
                }
                filmDistributedCommercially
                filmDistributedToPublic
              }
              licensedToColumbiaUniversity {
                acknowledgements
                credits
                dateOfLicense
                licenseDocumentationLocation
                terminationDateOfLicense
              }
              rightsForWorksOfArtSculptureAndPhotographs {
                childrenMateriallyIdentifiableInWork
                note
                privacyConcerns
                publicityRightsPresent
                sensitiveInNature
                trademarksProminentlyVisible
                varaRightsConcerns
              }
              underlyingRights {
                columbiaMusicLicense
                composition
                note
                other
                otherUnderlyingRights {
                  value
                }
                recording
                talentRights
              }
            }
          }
        }
      }
    GQL
  end
end
