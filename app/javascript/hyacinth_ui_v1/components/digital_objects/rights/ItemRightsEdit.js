import React from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Col, Form, Collapse } from 'react-bootstrap';

import ContextualNavbar from '../../layout/ContextualNavbar';
import SubmitButton from '../../layout/forms/SubmitButton';
import CancelButton from '../../layout/forms/CancelButton';
import Label from '../form/Label';
import InputGroup from '../form/InputGroup';
import BooleanRadioButtons from '../form/inputs/BooleanRadioButtons';

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
        countryOfOrigin: {},
        filmDistributedToPublic: '',
        filmDistributedCommercially: '',
      },
      copyrightStatus: {
        copyrightStatement: '',
        copyrightNote: [''],
        copyrightRegistered: '',
        copyrightRenewed: '',
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
        trademarksProminentlyVisible: '',
        sensitiveInNature: '',
        privacyConcerns: '',
        childrenMateriallyIdentifiableInWork: '',
        varaRightsConcerns: '',
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

  onChange(subsection, value) {
    this.setState(produce((draft) => {
      draft.rights[subsection] = value;
    }));
  }

  onSubmitHandler() {
    // To be implemented.
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
            { link: '/digital_objects', label: 'Cancel' },
          ]}
        />

        <Form className="mb-3">
          <DescriptiveMetadata
            dynamicFieldData={dynamicFieldData}
            value={descriptiveMetadata}
            onChange={v => this.onChange('descriptiveMetadata', v)}
          />

          <CopyrightStatus
            value={copyrightStatus}
            onChange={v => this.onChange('copyrightStatus', v)}
          />

          <InputGroup>
            <Label>Is there additional copyright or permissions information to record?</Label>
            <BooleanRadioButtons
              value={additionalRightsToRecord.enabled}
              onChange={v => this.onChange('additionalRightsToRecord', { enabled: v })}
            />
          </InputGroup>

          <Collapse in={additionalRightsToRecord.enabled}>
            <div>
              <CopyrightOwnership
                value={copyrightOwnership}
                onChange={v => this.onChange('copyrightOwnership', v)}
              />

              <ColumbiaUniversityIsCopyrightHolder
                value={columbiaUniversityIsCopyrightHolder}
                onChange={v => this.onChange('columbiaUniversityIsCopyrightHolder', v)}
              />

              <LicensedToColumbiaUniversity
                value={licensedToColumbiaUniversity}
                onChange={v => this.onChange('licensedToColumbiaUniversity', v)}
              />

              <ContractualLimitationsRestrictionsAndPermissions
                audioVisualContent={descriptiveMetadata.typeOfContent === 'motionPicture'}
                value={contractualLimitationsRestrictionsAndPermissions}
                onChange={v => this.onChange('contractualLimitationsRestrictionsAndPermissions', v)}
              />

              {
                descriptiveMetadata.typeOfContent === 'pictoralGraphicAndScuptural' && (
                  <RightsForWorksOfArtSculptureAndPhotographs
                    value={rightsForWorksOfArtSculptureAndPhotographs}
                    onChange={v => this.onChange('rightsForWorksOfArtSculptureAndPhotographs', v)}
                  />
                )
              }

              <UnderlyingRights
                value={underlyingRights}
                onChange={v => this.onChange('underlyingRights', v)}
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
