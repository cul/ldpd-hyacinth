import React, { useState } from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Form, Collapse } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { merge } from 'lodash';

import keyTransformer from '../../../../util/keyTransformer';
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
import defaultItemRights from './defaultItemRights';

function ItemRightsForm(props) {
  const { digitalObject } = props;
  const { id, rights: initialRights, dynamicFieldData } = digitalObject;
  const history = useHistory();

  const camelizedInitialRights = keyTransformer.deepCamelCase(initialRights);
  const [rights, setRights] = useState(merge({}, defaultItemRights(), camelizedInitialRights));
  const onChange = (subsection, value) => {
    setRights(produce(rights, (draft) => {
      draft[subsection] = value;
    }));
  };

  const onSubmitHandler = () => {
    return digitalObjectApi.rights.update(
      id,
      { digitalObject: { rights: keyTransformer.deepSnakeCase(rights) } },
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
            audioVisualContent={descriptiveMetadata.typeOfContent === 'motion_picture'}
            value={contractualLimitationsRestrictionsAndPermissions}
            onChange={v => onChange('contractualLimitationsRestrictionsAndPermissions', v)}
          />

          {
            descriptiveMetadata.typeOfContent === 'pictoral_graphic_and_scuptural' && (
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
