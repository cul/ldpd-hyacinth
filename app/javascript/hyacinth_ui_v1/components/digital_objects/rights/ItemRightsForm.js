import React from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Form, Collapse } from 'react-bootstrap';

import Label from '../../ui/forms/Label';
import InputGroup from '../../ui/forms/InputGroup';
import BooleanRadioButtons from '../../ui/forms/inputs/BooleanRadioButtons';
import { digitalObject } from '../../../util/hyacinth_api';
import digitalObjectInterface from '../digitalObjectInterface';
import TabHeading from '../../ui/tabs/TabHeading';
import FormButtons from '../../ui/forms/FormButtons';

import DescriptiveMetadata from './subsections/DescriptiveMetadata';
import CopyrightStatus from './subsections/CopyrightStatus';
import CopyrightOwnership from './subsections/CopyrightOwnership';
import ColumbiaUniversityIsCopyrightHolder from './subsections/ColumbiaUniversityIsCopyrightHolder';
import LicensedToColumbiaUniversity from './subsections/LicensedToColumbiaUniversity';
import ContractualLimitationsRestrictionsAndPermissions from './subsections/ContractualLimitationsRestrictionsAndPermissions';
import RightsForWorksOfArtSculptureAndPhotographs from './subsections/RightsForWorksOfArtSculptureAndPhotographs';
import UnderlyingRights from './subsections/UnderlyingRights';

class ItemRightsForm extends React.Component {
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


  // componentDidMount() {
  //   const { match: { params: { id } } } = this.props;
  //
  //   digitalObject.get(id)
  //     .then((res) => {
  //       this.setState(produce((draft) => {
  //         console.log('reloaded digital object data');
  //         draft.data = res.data.digitalObject;
  //       }));
  //     });
  // }

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

    const { id } = this.state;
    const { data } = this.props;

    return (
      <>
        <TabHeading>
          Rights
          {/* <EditButton
            className="float-right"
            size="lg"
            link={`/digital_objects/${id}/rights/edit`}
          /> */}
        </TabHeading>
        <Form key={id} className="digital-object-interface">
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
            <Label sm={4} align="right">Is there additional copyright or permissions information to record?</Label>
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

          <FormButtons
            formType="edit"
            // cancelTo={"/digital_object/:id/rights"}
            onSave={this.onSubmitHandler}
          />
        </Form>
      </>
    );
  }
}

ItemRightsForm.propTypes = {
  // dynamicFieldData: PropTypes.shape({
  //   title: PropTypes.shape({ titleSortPortion: PropTypes.string }),
  // }),
  data: PropTypes.any,
};

export default digitalObjectInterface(ItemRightsForm);
