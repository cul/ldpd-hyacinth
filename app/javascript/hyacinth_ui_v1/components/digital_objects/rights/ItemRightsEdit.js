import React from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Col, Form, Collapse } from 'react-bootstrap';

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
        a: false,
        b: false,
        c: false,
        d: false,
        e: false,
        avA: false,
        avB: false,
        avC: false,
        avD: false,
        avE: false,
        avF: false,
        avG: false,
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

    const { data, id } = this.props;

    return (
      <>
        <Form className="mb-3" key={id}>
          <DescriptiveMetadata
            dynamicFieldData={data ? data.dynamicFieldData : {}}
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

ItemRightsEdit.propTypes = {
  // dynamicFieldData: PropTypes.shape({
  //   title: PropTypes.shape({ titleSortPortion: PropTypes.string }),
  // }),
  data: PropTypes.any,
};

export default ItemRightsEdit;
