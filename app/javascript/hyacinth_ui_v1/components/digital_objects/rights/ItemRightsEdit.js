import React from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Col, Form, Collapse } from 'react-bootstrap';

import ContextualNavbar from '../../layout/ContextualNavbar';
import SubmitButton from '../../layout/forms/SubmitButton';
import CancelButton from '../../layout/forms/CancelButton';

import BooleanInputGroup from './form_inputs/BooleanInputGroup';

import DescriptiveMetadata from './subsections/DescriptiveMetadata';
import CopyrightStatus from './subsections/CopyrightStatus';
import CopyrightOwnership from './subsections/CopyrightOwnership';
import ColumbiaUniversityIsCopyrightHolder from './subsections/ColumbiaUniversityIsCopyrightHolder';
import LicensedToColumbiaUniversity from './subsections/LicensedToColumbiaUniversity';
import ContractualLimitationsRestrictionsAndPermissions from './subsections/ContractualLimitationsRestrictionsAndPermissions';
import RightsForWorksOfArtSculptureAndPhotographs from './subsections/RightsForWorksOfArtSculptureAndPhotographs';
import UnderlyingRights from './subsections/UnderlyingRights';

class ItemRightsEdit extends React.Component {
  state = {
    rights: {
      descriptiveMetadata: {
        typeOfContent: '',
        countryOfOrigin: '',
        filmDistributedToPublic: false,
        filmDistributedCommercially: false,
      },
      copyrightStatus: {
        copyrightStatement: '',
        copyrightNote: [''],
        copyrightRegistered: false,
        copyrightRenewed: false,
        copyrightDateOfRenewal: '',
        copyrightExpirationDate: '',
        culCopyrightAssessmentDate: '',
      },
      additionalRightsToRecord: {
        enabled: false,
      },
      copyrightOwnership: {
        enabled: false,
        copyrightOwners: [
          {
            name: {},
            heirs: '',
            contactInformation: '',
          },
        ],
      },
      columbiaUniversityIsCopyrightHolder: {
        enabled: false,
        dateOfTransfer: '',
        dateOfExpiration: '',
        transferDocumentionEnabled: false,
        transferDocumentation: '',
        otherTransferEvidenceEnabled: false,
        otherTransferEvidence: '',
        transferDocumentationNote: '',
      },
      licensedToColumbiaUniversity: {
        enabled: false,
        dateOfLicense: '',
        terminationDateOfLicense: '',
        credits: '',
        acknowledgements: '',
        licenseDocumentationLocation: '',
      },
      contractualLimitationsRestrictionsAndPermissions: {
        enabled: false,
        onsiteResearch: [],
        reproductionAndDistributionProhibitedUntil: '',
        photoGraphicOrFilmCredit: '',
        excerptLimitedTo: '',
        other: '',
        permissionsGrantedAsPartOfTheUseLicenseEnabled: false,
        permissionsGrantedAsPartOfTheUseLicense: [],
      },
      rightsForWorksOfArtSculptureAndPhotographs: {
        enabled: false,
        publicityRightsPresentEnabled: false,
        publicityRightsPresent: '',
        trademarksProminentlyVisible: false,
        sensitiveInNature: false,
        privacyConcerns: false,
        childrenMateriallyIdentifiableInWork: false,
        varaRightsConcerns: false,
        note: '',
      },
      underlyingRights: {
        enabled: false,
        doWeKnowSpecificUnderlyingRightsEnabled: false,
        note: '',
        musicRightsEnabled: false,
        talentRights: '',
        musicLicensedToColumbiaEnabled: false,
        columbiaMusicLicense: '',
        composition: '',
        recording: '',
        otherUnderlyingRights: [],
        other: '',
      },
    },
  }

  onChangeHandler(subsection, fieldName, value) {
    this.setState(produce((draft) => {
      draft.rights[subsection][fieldName] = value;
    }));
  }

  onCopyrightOwnerChange = (index, fieldName, value) => {
    this.setState(produce((draft) => {
      draft.rights.copyrightOwnership.copyrightOwners[parseInt(index)][fieldName] = value;
    }));
  }

  onSubmitHandler() {
    // To be implemented.
  }

  addCopyrightOwner = () => {
    this.setState(produce((draft) => {
      draft.rights.copyrightOwnership.copyrightOwners.push(
        { name: '', heirs: '', contactInformation: '' }
      );
    }));
  }

  removeCopyrightOwner = (index) => {
    this.setState(produce((draft) => {
      draft.rights.copyrightOwnership.copyrightOwners.splice(index, 1);
    }));
  }

  render() {
    const {
      rights: {
        descriptiveMetadata,
        copyrightStatus,
        additionalRightsToRecord,
        copyrightOwnership,
        columbiaUniversityIsCopyrightHolder,
        licensedToColumbiaUniversity,
        contractualLimitationsRestrictionsAndPermissions,
        rightsForWorksOfArtSculptureAndPhotographs,
        underlyingRights,
      },
    } = this.state;

    const { dynamicFieldData } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Editing Item Rights"
          rightHandLinks={[
            { link: '/digital_objects/1', label: 'Cancel' },
          ]}
        />

        <Form className="mb-3">
          <DescriptiveMetadata
            dynamicFieldData={dynamicFieldData}
            value={descriptiveMetadata}
            onChange={(fieldName, value) => this.onChangeHandler('descriptiveMetadata', fieldName, value)}
          />

          <CopyrightStatus
            value={copyrightStatus}
            onChange={(fieldName, value) => this.onChangeHandler('copyrightStatus', fieldName, value)}
          />

          <BooleanInputGroup
            label="Is there additional copyright or permissions information to record?"
            inputName="enabled"
            value={additionalRightsToRecord.enabled}
            onChange={(fieldName, value) => this.onChangeHandler('additionalRightsToRecord', fieldName, value)}
          />

          <Collapse in={additionalRightsToRecord.enabled}>
            <div>
              <CopyrightOwnership
                value={copyrightOwnership}
                addCopyrightOwner={this.addCopyrightOwner}
                removeCopyrightOwner={this.removeCopyrightOwner}
                onCopyrightOwnerChange={this.onCopyrightOwnerChange}
                onChange={(fieldName, value) => this.onChangeHandler('copyrightOwnership', fieldName, value)}
              />

              <ColumbiaUniversityIsCopyrightHolder
                value={columbiaUniversityIsCopyrightHolder}
                onChange={(fieldName, value) => this.onChangeHandler('columbiaUniversityIsCopyrightHolder', fieldName, value)}
              />

              <LicensedToColumbiaUniversity
                value={licensedToColumbiaUniversity}
                onChange={(fieldName, value) => this.onChangeHandler('licensedToColumbiaUniversity', fieldName, value)}
              />

              <ContractualLimitationsRestrictionsAndPermissions
                audioVisualContent={descriptiveMetadata.typeOfContent === 'motionPicture'}
                value={contractualLimitationsRestrictionsAndPermissions}
                onChange={(fieldName, value) => this.onChangeHandler('contractualLimitationsRestrictionsAndPermissions', fieldName, value)}
              />

              {
                descriptiveMetadata.typeOfContent === 'pictoralGraphicAndScuptural' && (
                  <RightsForWorksOfArtSculptureAndPhotographs
                    value={rightsForWorksOfArtSculptureAndPhotographs}
                    onChange={(fieldName, value) => this.onChangeHandler('rightsForWorksOfArtSculptureAndPhotographs', fieldName, value)}
                  />
                )
              }

              <UnderlyingRights
                value={underlyingRights}
                onChange={(fieldName, value) => this.onChangeHandler('underlyingRights', fieldName, value)}
              />
            </div>
          </Collapse>

          <Form.Row>
            <Col sm="auto">
              <CancelButton to="/digital_object/:id/rights" />
            </Col>

            <Col sm="auto" className="ml-auto">
              <SubmitButton formType="edit" onClick={this.onSubmitHandler} />
            </Col>
          </Form.Row>
        </Form>
      </>
    );
  }
}

ItemRightsEdit.defaultProps = {
  dynamicFieldData: {
    title: [
      {
        titleSortPortion: 'Catcher in the Rye',
        titleNonSortPortion: 'The',
      },
    ],
    alternativeTitle: [
      {
        alternativeTitleValue: 'That book everybody reads',
      },
    ],
    name: [
      {
        nameTerm: {
          value: 'Salinger, J. D.',
          uni: 'jds1329',
          uri: 'http://id.loc.gov/authorities/names/n50016589',
        },
        nameRole: [
          {
            nameRoleTerm: {
              value: 'Author',
              uri: 'http://id.loc.gov/roles/123',
            },
          },
        ],
      },
      {
        nameTerm: {
          value: 'E. Michael Mitchell',
          uri: 'http://id.loc.gov/authorities/names/n79006fasdfsf779',
        },
        nameRole: [
          {
            nameRoleTerm: {
              value: 'Illustrator',
              uri: 'http://id.loc.gov/roles/456',
            },
          },
          {
            nameRoleTerm: {
              value: 'Creator',
              uri: 'http://id.loc.gov/roles/789',
            },
          },
        ],
      },
    ],
    publisher: [
      {
        publisherValue: 'Little, Brown and Company',
      },
    ],
    dateCreated: [
      {
        dateCreatedStartValue: '',
        dateCreatedEndValue: '1951-07-16',
        dateCreatedType: '',
        dateCreatedKeyDate: '',
      },
    ],
    dateCreatedTextual: [
      {
        dateCreatedTextualValue: '',
      },
    ],
    genre: [
      {
        genreTerm: {
          uri: 'http://vocab.getty.edu/aat/300028028',
          value: 'Theses',
          type: 'external',
          authority: 'aat',
          vocabulary_string_key: 'genre',
          internal_id: 196177,
        },
      },
    ],
    form: [
      {
        formTerm: {
          uri: 'http://vocab.getty.edu/aat/300026690',
          value: 'albums',
          type: 'external',
          authority: 'aat',
          vocabulary_string_key: 'form',
          internal_id: 370547,
        },
      },
    ],
  },
};

ItemRightsEdit.propTypes = {
  // dynamicFieldData: PropTypes.shape({
  //   title: PropTypes.shape({ titleSortPortion: PropTypes.string }),
  // }),
  dynamicFieldData: PropTypes.any,
};

export default ItemRightsEdit;
