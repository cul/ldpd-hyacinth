import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Form, Collapse } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { merge, omit, isEmpty, cloneDeep } from 'lodash';
import { useMutation } from '@apollo/react-hooks';

import Label from '../../../shared/forms/Label';
import InputGroup from '../../../shared/forms/InputGroup';
import BooleanRadioButtons from '../../../shared/forms/inputs/BooleanRadioButtons';
import FormButtons from '../../../shared/forms/FormButtons';
import { updateItemRightsMutation } from '../../../../graphql/digitalObjects';
import GraphQLErrors from '../../../shared/GraphQLErrors';

import DescriptiveMetadata from './subsections/DescriptiveMetadata';
import CopyrightStatus from './subsections/CopyrightStatus';
import CopyrightOwnership from './subsections/CopyrightOwnership';
import ColumbiaUniversityIsCopyrightHolder from './subsections/ColumbiaUniversityIsCopyrightHolder';
import LicensedToColumbiaUniversity from './subsections/LicensedToColumbiaUniversity';
import ContractualLimitationsRestrictionsAndPermissions from './subsections/ContractualLimitationsRestrictionsAndPermissions';
import RightsForWorksOfArtSculptureAndPhotographs from './subsections/RightsForWorksOfArtSculptureAndPhotographs';
import UnderlyingRights from './subsections/UnderlyingRights';
import { defaultItemRights } from './defaultRights';
import { removeTypename, removeEmptyKeys } from '../../../../utils/deepKeyRemove';
import keyTransformer from '../../../../utils/keyTransformer';

import { useEnabled, useHash } from './rightsHooks';

function ItemRightsForm(props) {
  const { digitalObject: { id, rights: initialRights, dynamicFieldData } } = props;

  const history = useHistory();

  const [rights, setRights] = useHash(merge({}, defaultItemRights, removeTypename(removeEmptyKeys(initialRights))));

  const [updateRights, { error: updateError }] = useMutation(updateItemRightsMutation);

  const [enabledAdditionalRights, setEnabledAdditionalRights] = useEnabled(
    omit(rights, 'descriptiveMetadata', 'copyrightStatus'),
    () => {
      // if no longer adding additional rights need to reset all sections
      // but descriptiveMetadata and copyrightStatus
      setRights(
        'rightsForWorksOfArtSculptureAndPhotographs',
        cloneDeep(defaultItemRights.rightsForWorksOfArtSculptureAndPhotographs),
      );
      setRights('copyrightOwnership', cloneDeep(defaultItemRights.copyrightOwnership));
      setRights('columbiaUniversityIsCopyrightHolder', cloneDeep(defaultItemRights.columbiaUniversityIsCopyrightHolder));
      setRights('licensedToColumbiaUniversity', cloneDeep(defaultItemRights.licensedToColumbiaUniversity));
      setRights('contractualLimitationsRestrictionsAndPermissions', cloneDeep(defaultItemRights.contractualLimitationsRestrictionsAndPermissions));
      setRights('underlyingRights', cloneDeep(defaultItemRights.underlyingRights));
    },
  );

  const onSubmitHandler = () => {
    const cleanRights = removeEmptyKeys(removeTypename(rights));
    const variables = { input: merge({ id }, cleanRights) };
    return updateRights({ variables }).then(res => history.push(`/digital_objects/${res.data.updateItemRights.item.id}/rights`));
  };

  const typeOfContentChange = (type) => {
    if (type !== 'motion_picture') {
      setRights('descriptiveMetadata', produce((draft) => {
        draft[0].filmDistributedToPublic = '';
        draft[0].filmDistributedCommercially = '';
      }));

      setRights('contractualLimitationsRestrictionsAndPermissions', produce((draft) => {
        draft[0].optionAvA = false;
        draft[0].optionAvB = false;
        draft[0].optionAvC = false;
        draft[0].optionAvD = false;
        draft[0].optionAvE = false;
        draft[0].optionAvF = false;
        draft[0].optionAvG = false;
        draft[0].excerptLimitedTo = '';
      }));
    }

    if (type !== 'pictoral_graphic_and_scuptural') {
      // reset the entire section dedicated to that type
      setRights(
        'rightsForWorksOfArtSculptureAndPhotographs',
        [{ ...defaultItemRights.rightsForWorksOfArtSculptureAndPhotographs[0] }],
      );
    }
  };

  const {
    descriptiveMetadata,
    copyrightStatus,
    copyrightOwnership,
    columbiaUniversityIsCopyrightHolder,
    licensedToColumbiaUniversity,
    contractualLimitationsRestrictionsAndPermissions,
    rightsForWorksOfArtSculptureAndPhotographs,
    underlyingRights,
  } = rights;

  return (
    <Form key={id} className="digital-object-interface">
      <GraphQLErrors errors={updateError} />

      <DescriptiveMetadata
        dynamicFieldData={keyTransformer.deepCamelCase(dynamicFieldData)}
        values={descriptiveMetadata}
        onChange={v => setRights('descriptiveMetadata', v)}
        typeOfContentChange={typeOfContentChange}
      />

      <CopyrightStatus
        values={copyrightStatus}
        onChange={v => setRights('copyrightStatus', v)}
      />

      <InputGroup>
        <Label sm={4} align="right">Is there additional copyright or permissions information to record?</Label>
        <BooleanRadioButtons value={enabledAdditionalRights} onChange={setEnabledAdditionalRights} />
      </InputGroup>

      <Collapse in={enabledAdditionalRights}>
        <div>
          <CopyrightOwnership
            values={copyrightOwnership}
            onChange={v => setRights('copyrightOwnership', v)}
          />

          <ColumbiaUniversityIsCopyrightHolder
            values={columbiaUniversityIsCopyrightHolder}
            onChange={v => setRights('columbiaUniversityIsCopyrightHolder', v)}
          />

          <LicensedToColumbiaUniversity
            values={licensedToColumbiaUniversity}
            onChange={v => setRights('licensedToColumbiaUniversity', v)}
          />

          <ContractualLimitationsRestrictionsAndPermissions
            audioVisualContent={descriptiveMetadata[0].typeOfContent === 'motion_picture'}
            values={contractualLimitationsRestrictionsAndPermissions}
            onChange={v => setRights('contractualLimitationsRestrictionsAndPermissions', v)}
          />

          {
            descriptiveMetadata[0].typeOfContent === 'pictoral_graphic_and_scuptural' && (
              <RightsForWorksOfArtSculptureAndPhotographs
                values={rightsForWorksOfArtSculptureAndPhotographs}
                onChange={v => setRights('rightsForWorksOfArtSculptureAndPhotographs', v)}
              />
            )
          }

          <UnderlyingRights
            values={underlyingRights}
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
