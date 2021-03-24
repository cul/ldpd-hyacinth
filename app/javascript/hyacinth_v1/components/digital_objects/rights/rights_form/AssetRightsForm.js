import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { merge } from 'lodash';
import { useMutation } from '@apollo/react-hooks';

import FormButtons from '../../../shared/forms/FormButtons';
import { useHash } from './rightsHooks';
import { updateRightsMutation } from '../../../../graphql/digitalObjects';
import ErrorList from '../../../shared/ErrorList';
import { removeTypename, removeEmptyKeys } from '../../../../utils/deepKeyRemove';
import { defaultFieldValues } from '../../common/defaultFieldValues';
import FieldGroupArray from './fields/FieldGroupArray';

function AssetRightsForm(props) {
  const {
    fieldConfiguration,
    digitalObject: {
      id,
      optimisticLockToken,
      primaryProject: { hasAssetRights },
      rights: initialRights,
    },
  } = props;
  const history = useHistory();

  const defaultAssetRights = defaultFieldValues(fieldConfiguration);

  const [rights, setRights] = useHash(merge({}, defaultAssetRights, initialRights));

  const [updateRights, { data: updateData }] = useMutation(updateRightsMutation);

  // One day, maybe enable optionalChaining JS feature in babel to simplify lines like the one below.
  const userErrors = (updateData && updateData.updateRights && updateData.updateRights.userErrors) || [];


  const onSubmitHandler = () => {
    const cleanRights = removeEmptyKeys(removeTypename(rights));
    const variables = { input: { id, rights: cleanRights, optimisticLockToken } };

    return updateRights({ variables }).then(res => history.push(`/digital_objects/${res.data.updateRights.digitalObject.id}/rights`));
  };

  if (!hasAssetRights) {
    delete rights.copyright_status_override;
  }

  const findFieldConfig = stringKey => fieldConfiguration.find(c => c.stringKey === stringKey);

  if (fieldConfiguration.length === 0) return (<p>Rights field configuration missing.</p>);

  return (
    <Form className="mb-3">
      <ErrorList errors={userErrors.map((userError) => (`${userError.message} (path=${userError.path.join('/')})`))} />

      <FieldGroupArray
        value={rights.restriction_on_access}
        defaultValue={defaultAssetRights.restriction_on_access[0]}
        dynamicFieldGroup={findFieldConfig('restriction_on_access')}
        onChange={v => setRights('restriction_on_access', v)}
      />

      {
        hasAssetRights && (
          <FieldGroupArray
            value={rights.copyright_status_override}
            defaultValue={defaultAssetRights.copyright_status_override[0]}
            dynamicFieldGroup={findFieldConfig('copyright_status_override')}
            onChange={v => setRights('copyright_status_override', v)}
          />
        )
      }
      <FormButtons
        formType="edit"
        cancelTo={`/digital_objects/${id}/rights`}
        onSave={onSubmitHandler}
      />
    </Form>
  );
}

export default AssetRightsForm;

AssetRightsForm.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
};
