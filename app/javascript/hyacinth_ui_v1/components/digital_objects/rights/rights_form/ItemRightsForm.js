import React, { useState } from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Form, Collapse } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { merge } from 'lodash';

import Label from '../../../ui/forms/Label';
import InputGroup from '../../../ui/forms/InputGroup';
import BooleanRadioButtons from '../../../ui/forms/inputs/BooleanRadioButtons';
import { digitalObject as digitalObjectApi } from '../../../../util/hyacinth_api';
import FormButtons from '../../../ui/forms/FormButtons';

import DescriptiveMetadata from './subsections/DescriptiveMetadata';
import CopyrightStatus from './subsections/CopyrightStatus';
import CopyrightOwnership from './subsections/CopyrightOwnership';
import ColumbiaUniversityIsCopyrightHolder from './subsections/ColumbiaUniversityIsCopyrightHolder';
import LicensedToColumbiaUniversity from './subsections/LicensedToColumbiaUniversity';
import ContractualLimitationsRestrictionsAndPermissions from './subsections/ContractualLimitationsRestrictionsAndPermissions';
import RightsForWorksOfArtSculptureAndPhotographs from './subsections/RightsForWorksOfArtSculptureAndPhotographs';
import UnderlyingRights from './subsections/UnderlyingRights';

function ItemRightsForm(props) {
  const { digitalObject } = props;
  const { id, rights: initialRights, dynamicFieldData } = digitalObject;
  const history = useHistory();

  const defaultRights = () => ({
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

  const [rights, setRights] = useState(merge({}, defaultRights(), initialRights));

  const onChange = (subsection, value) => {
    setRights(produce(rights, (draft) => {
      draft[subsection] = value;
    }));
  };

  const onSubmitHandler = () => {
    return digitalObjectApi.rights.update(
      id,
      { digitalObject: { rights } },
    ).then(res => history.push(`/digital_objects/${res.data.digitalObject.uid}/rights`));
  };

  const {
    descriptiveMetadata,
    copyrightStatus,
    additionalRightsToRecord,
    copyrightOwnership,
    columbiaUniversityIsCopyrightHolder,
    licensedToColumbiaUniversity,
    contractualLimitationsRestrictionsAndPermissions,
    rightsForWorksOfArtSculptureAndPhotographs,
    underlyingRights,
  } = rights;

  return (
    <Form key={id} className="digital-object-interface">
      <DescriptiveMetadata
        dynamicFieldData={dynamicFieldData}
        value={descriptiveMetadata}
        onChange={v => onChange('descriptiveMetadata', v)}
      />

      <CopyrightStatus
        value={copyrightStatus}
        onChange={v => onChange('copyrightStatus', v)}
      />

      <InputGroup>
        <Label sm={4} align="right">Is there additional copyright or permissions information to record?</Label>
        <BooleanRadioButtons
          value={additionalRightsToRecord.enabled}
          onChange={v => onChange('additionalRightsToRecord', { enabled: v })}
        />
      </InputGroup>

      <Collapse in={additionalRightsToRecord.enabled}>
        <div>
          <CopyrightOwnership
            value={copyrightOwnership}
            onChange={v => onChange('copyrightOwnership', v)}
          />

          <ColumbiaUniversityIsCopyrightHolder
            value={columbiaUniversityIsCopyrightHolder}
            onChange={v => onChange('columbiaUniversityIsCopyrightHolder', v)}
          />

          <LicensedToColumbiaUniversity
            value={licensedToColumbiaUniversity}
            onChange={v => onChange('licensedToColumbiaUniversity', v)}
          />

          <ContractualLimitationsRestrictionsAndPermissions
            audioVisualContent={descriptiveMetadata.typeOfContent === 'motionPicture'}
            value={contractualLimitationsRestrictionsAndPermissions}
            onChange={v => onChange('contractualLimitationsRestrictionsAndPermissions', v)}
          />

          {
            descriptiveMetadata.typeOfContent === 'pictoralGraphicAndScuptural' && (
              <RightsForWorksOfArtSculptureAndPhotographs
                value={rightsForWorksOfArtSculptureAndPhotographs}
                onChange={v => onChange('rightsForWorksOfArtSculptureAndPhotographs', v)}
              />
            )
          }

          <UnderlyingRights
            value={underlyingRights}
            onChange={v => onChange('underlyingRights', v)}
          />
        </div>
      </Collapse>

      <FormButtons
        formType="edit"
        cancelTo={`/digital_objects/${id}/rights`}
        onSave={onSubmitHandler}
      />
    </Form>
  );
}

export default ItemRightsForm;

ItemRightsForm.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
};
