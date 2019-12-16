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
  constructor(props) {
    super(props);
    const { rights } = props.data;
    this.state = {
      rights: Object.entries(rights).length ? rights : this.defaultRights(),
    };
  }

  // componentDidMount() {,
  //   // On mount, we want to retrieve the latest version of the rights data
  //   // because this rights form saves and reloads separately from any other
  //   // form in the tabbed digital object interface.
  //   digitalObject.get(this.props.uid)
  //     .then((res) => {
  //       this.setState(produce((draft) => {
  //         const { rights } = res.data.digitalObject;
  //
  //         // Rights property may be null if this object hasn't been assigned,
  //         // rights yet (TODO: confirm that this is true), so we'll want
  //         draft.rights = rights || this.defaultRights();
  //       }));
  //     });
  // }

  onChange(subsection, value) {
    this.setState(produce((draft) => {
      draft.rights[subsection] = value;
    }));
  }

  onSubmitHandler = () => {
    const { data: { uid } } = this.props;
    const { history: { push } } = this.props;
    const { rights } = this.state;

    return digitalObject.update(
      uid,
      { digitalObject: { rights } },
    ).then(res => push(`/digital_objects/${res.data.digitalObject.uid}/rights`));
  }

  defaultRights = () => ({
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
  });

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

    const { data: { uid } } = this.props;
    const { data } = this.props;

    return (
      <>
        <TabHeading>
          Rights
          {/* <EditButton
            className="float-right"
            size="lg"
            link={`/digital_objects/${uid}/rights/edit`}
          /> */}
        </TabHeading>
        <Form key={uid} className="digital-object-interface">
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
            cancelTo={`/digital_objects/${uid}/rights`}
            onSave={this.onSubmitHandler}
          />
        </Form>
      </>
    );
  }
}

export default digitalObjectInterface(ItemRightsForm);
