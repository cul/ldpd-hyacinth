import React, { useState } from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Form, Collapse } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { merge } from 'lodash';

import keyTransformer from '../../../../utils/keyTransformer';
import Label from '../../../shared/forms/Label';
import InputGroup from '../../../shared/forms/InputGroup';
import BooleanRadioButtons from '../../../shared/forms/inputs/BooleanRadioButtons';
import { digitalObject as digitalObjectApi } from '../../../../utils/hyacinth_api';
import FormButtons from '../../../shared/forms/FormButtons';

import DescriptiveMetadata from './subsections/DescriptiveMetadata';
import CopyrightStatus from './subsections/CopyrightStatus';
import CopyrightOwnership from './subsections/CopyrightOwnership';
import ColumbiaUniversityIsCopyrightHolder from './subsections/ColumbiaUniversityIsCopyrightHolder';
import LicensedToColumbiaUniversity from './subsections/LicensedToColumbiaUniversity';
import ContractualLimitationsRestrictionsAndPermissions from './subsections/ContractualLimitationsRestrictionsAndPermissions';
import RightsForWorksOfArtSculptureAndPhotographs from './subsections/RightsForWorksOfArtSculptureAndPhotographs';
import UnderlyingRights from './subsections/UnderlyingRights';
import { defaultItemRights } from './defaultItemRights';

const useHash = (initialHash) => {
  const [hash, setHash] = useState(initialHash);

  const setHashViaKey = (key, value) => setHash(produce(hash, (draft) => { draft[key] = value; }));

  return [hash, setHashViaKey];
};

function ItemRightsForm(props) {
  const { digitalObject: { id, rights: initialRights, dynamicFieldData } } = props;
  const history = useHistory();

  const camelizedInitialRights = keyTransformer.deepCamelCase(initialRights);
  const [rights, setRights] = useHash(merge({}, defaultItemRights(), camelizedInitialRights));

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
        onChange={v => setRights('descriptiveMetadata', v)}
      />

      <CopyrightStatus
        value={copyrightStatus}
        onChange={v => setRights('copyrightStatus', v)}
      />

      <InputGroup>
        <Label sm={4} align="right">Is there additional copyright or permissions information to record?</Label>
        <BooleanRadioButtons
          value={additionalRightsToRecord.enabled}
          onChange={v => setRights('additionalRightsToRecord', { enabled: v })}
        />
      </InputGroup>

      <Collapse in={additionalRightsToRecord.enabled}>
        <div>
          <CopyrightOwnership
            value={copyrightOwnership}
            onChange={v => setRights('copyrightOwnership', v)}
          />

          <ColumbiaUniversityIsCopyrightHolder
            value={columbiaUniversityIsCopyrightHolder}
            onChange={v => setRights('columbiaUniversityIsCopyrightHolder', v)}
          />

          <LicensedToColumbiaUniversity
            value={licensedToColumbiaUniversity}
            onChange={v => setRights('licensedToColumbiaUniversity', v)}
          />

          <ContractualLimitationsRestrictionsAndPermissions
            audioVisualContent={descriptiveMetadata.typeOfContent === 'motion_picture'}
            value={contractualLimitationsRestrictionsAndPermissions}
            onChange={v => setRights('contractualLimitationsRestrictionsAndPermissions', v)}
          />

          {
            descriptiveMetadata.typeOfContent === 'pictoral_graphic_and_scuptural' && (
              <RightsForWorksOfArtSculptureAndPhotographs
                value={rightsForWorksOfArtSculptureAndPhotographs}
                onChange={v => setRights('rightsForWorksOfArtSculptureAndPhotographs', v)}
              />
            )
          }

          <UnderlyingRights
            value={underlyingRights}
            onChange={v => setRights('underlyingRights', v)}
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
