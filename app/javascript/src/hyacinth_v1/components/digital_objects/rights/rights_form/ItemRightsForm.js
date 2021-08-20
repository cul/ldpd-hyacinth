import React from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Form, Collapse } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { omit, cloneDeep } from 'lodash';
import { useMutation } from '@apollo/react-hooks';

import Label from '../../../shared/forms/Label';
import InputGroup from '../../../shared/forms/InputGroup';
import BooleanRadioButtons from '../../../shared/forms/inputs/BooleanRadioButtons';
import FormButtons from '../../../shared/forms/FormButtons';
import { updateRightsMutation } from '../../../../graphql/digitalObjects';
import ErrorList from '../../../shared/ErrorList';
import GraphQLErrors from '../../../shared/GraphQLErrors';

import DescriptiveMetadata from './subsections/DescriptiveMetadata';
import CopyrightOwnership from './subsections/CopyrightOwnership';
import ColumbiaUniversityIsCopyrightHolder from './subsections/ColumbiaUniversityIsCopyrightHolder';
import LicensedToColumbiaUniversity from './subsections/LicensedToColumbiaUniversity';
import ContractualLimitationsRestrictionsAndPermissions from './subsections/ContractualLimitationsRestrictionsAndPermissions';
import RightsForWorksOfArtSculptureAndPhotographs from './subsections/RightsForWorksOfArtSculptureAndPhotographs';
import UnderlyingRights from './subsections/UnderlyingRights';
import { removeTypename, removeEmptyKeys } from '../../../../utils/deepKeyRemove';
import keyTransformer from '../../../../utils/keyTransformer';
import { defaultFieldValues, mergeDefaultValues } from '../../common/defaultFieldValues';
import { useEnabled, useHash } from './rightsHooks';
import FieldGroupArray from './fields/FieldGroupArray';

function ItemRightsForm(props) {
  const { fieldConfiguration,
    digitalObject: {
      id, rights: initialRights, descriptiveMetadata, optimisticLockToken,
    },
  } = props;
  const history = useHistory();

  const defaultItemRights = defaultFieldValues(fieldConfiguration);

  const [rights, setRights] = useHash(mergeDefaultValues(fieldConfiguration, initialRights));

  const [updateRights, { data: updateData, error: updateError }] = useMutation(updateRightsMutation);

  // One day, maybe enable optionalChaining JS feature in babel to simplify lines like the one below.
  const userErrors = (updateData && updateData.updateRights && updateData.updateRights.userErrors) || [];

  const [enabledAdditionalRights, setEnabledAdditionalRights] = useEnabled(
    omit(rights, 'descriptive_metadata', 'copyright_status'),
    () => {
      // if no longer adding additional rights need to reset all sections
      // but descriptiveMetadata and copyrightStatus
      setRights(
        'rights_for_works_of_art_sculpture_and_photographs',
        cloneDeep(defaultItemRights.rights_for_works_of_art_sculpture_and_photographs),
      );
      setRights('copyright_ownership', cloneDeep(defaultItemRights.copyright_ownership));
      setRights('columbia_university_is_copyright_holder', cloneDeep(defaultItemRights.columbia_university_is_copyright_holder));
      setRights('licensed_to_columbia_university', cloneDeep(defaultItemRights.licensed_to_columbia_university));
      setRights('contractual_limitations_restrictions_and_permissions', cloneDeep(defaultItemRights.contractual_limitations_restrictions_and_permissions));
      setRights('underlying_rights', cloneDeep(defaultItemRights.underlying_rights));
    },
  );

  const saveSuccessHandler = (result) => {
    history.push(`/digital_objects/${result.data.updateRights.digitalObject.id}/rights`);
  };

  const onSaveHandler = () => {
    const cleanRights = removeEmptyKeys(removeTypename(rights));
    const variables = { input: { id, rights: cleanRights, optimisticLockToken } };
    return updateRights({ variables });
  };

  const typeOfContentChange = (type) => {
    if (type !== 'motion_picture') {
      setRights('descriptive_metadata', produce((draft) => {
        draft[0].film_distributed_to_public = '';
        draft[0].film_distributed_commercially = '';
      }));

      setRights('contractual_limitations_restrictions_and_permissions', produce((draft) => {
        draft[0].option_av_a = false;
        draft[0].option_av_b = false;
        draft[0].option_av_c = false;
        draft[0].option_av_d = false;
        draft[0].option_av_e = false;
        draft[0].option_av_f = false;
        draft[0].option_av_g = false;
        draft[0].excerpt_limited_to = '';
      }));
    }

    if (type !== 'pictoral_graphic_and_scuptural') {
      // reset the entire section dedicated to that type
      setRights(
        'rights_for_works_of_art_sculpture_and_photographs',
        [{ ...defaultItemRights.rights_for_works_of_art_sculpture_and_photographs[0] }],
      );
    }
  };

  const findFieldConfig = stringKey => fieldConfiguration.find(c => c.stringKey === stringKey);

  if (fieldConfiguration.length === 0) return (<p>Rights field configuration missing.</p>);

  return (
    <Form key={id} className="digital-object-interface">
      <GraphQLErrors errors={updateError} />
      <ErrorList errors={userErrors.map((userError) => (`${userError.message} (path=${userError.path.join('/')})`))} />

      <DescriptiveMetadata
        descriptiveMetadata={keyTransformer.deepCamelCase(descriptiveMetadata)}
        values={rights.descriptive_metadata}
        onChange={(v) => setRights('descriptive_metadata', v)}
        typeOfContentChange={typeOfContentChange}
        fieldConfig={findFieldConfig('descriptive_metadata')}
      />

      <FieldGroupArray
        value={rights.copyright_status}
        defaultValue={defaultItemRights.copyright_status[0]}
        dynamicFieldGroup={findFieldConfig('copyright_status')}
        onChange={(v) => setRights('copyright_status', v)}
      />

      <InputGroup>
        <Label sm={4} align="right">Is there additional copyright or permissions information to record?</Label>
        <BooleanRadioButtons value={enabledAdditionalRights} onChange={setEnabledAdditionalRights} />
      </InputGroup>

      <Collapse in={enabledAdditionalRights}>
        <div>
          <CopyrightOwnership
            values={rights.copyright_ownership}
            defaultValue={defaultItemRights.copyright_ownership[0]}
            onChange={(v) => setRights('copyright_ownership', v)}
            fieldConfig={findFieldConfig('copyright_ownership')}
          />

          <ColumbiaUniversityIsCopyrightHolder
            values={rights.columbia_university_is_copyright_holder}
            onChange={(v) => setRights('columbia_university_is_copyright_holder', v)}
            fieldConfig={findFieldConfig('columbia_university_is_copyright_holder')}
            defaultValue={defaultItemRights.columbia_university_is_copyright_holder[0]}
          />

          <LicensedToColumbiaUniversity
            values={rights.licensed_to_columbia_university}
            onChange={(v) => setRights('licensed_to_columbia_university', v)}
            fieldConfig={findFieldConfig('licensed_to_columbia_university')}
            defaultValue={defaultItemRights.licensed_to_columbia_university[0]}
          />

          <ContractualLimitationsRestrictionsAndPermissions
            audioVisualContent={rights.descriptive_metadata[0].type_of_content === 'motion_picture'}
            values={rights.contractual_limitations_restrictions_and_permissions}
            onChange={(v) => setRights('contractual_limitations_restrictions_and_permissions', v)}
            defaultValue={defaultItemRights.contractual_limitations_restrictions_and_permissions[0]}
            fieldConfig={findFieldConfig('contractual_limitations_restrictions_and_permissions')}
          />

          {
            rights.descriptive_metadata[0].type_of_content === 'pictoral_graphic_and_scuptural' && (
              <RightsForWorksOfArtSculptureAndPhotographs
                values={rights.rights_for_works_of_art_sculpture_and_photographs}
                onChange={(v) => setRights('rights_for_works_of_art_sculpture_and_photographs', v)}
                defaultValue={defaultItemRights.rights_for_works_of_art_sculpture_and_photographs[0]}
                fieldConfig={findFieldConfig('rights_for_works_of_art_sculpture_and_photographs')}
              />
            )
          }

          <UnderlyingRights
            values={rights.underlying_rights}
            onChange={(v) => setRights('underlying_rights', v)}
            defaultValue={defaultItemRights.underlying_rights[0]}
            fieldConfig={findFieldConfig('underlying_rights')}
          />
        </div>
      </Collapse>

      <FormButtons
        formType="edit"
        cancelTo={`/digital_objects/${id}/rights`}
        onSave={onSaveHandler}
        onSaveSuccess={saveSuccessHandler}
      />
    </Form>
  );
}

export default ItemRightsForm;

ItemRightsForm.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
};
