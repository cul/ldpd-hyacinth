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
import GraphQLErrors from '../../../shared/GraphQLErrors';
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

  const [updateRights, { data: updateData, error: updateError }] = useMutation(updateRightsMutation);

  // One day, maybe enable optionalChaining JS feature in babel to simplify lines like the one below.
  const userErrors = (updateData && updateData.updateRights && updateData.updateRights.userErrors) || [];

  const saveSuccessHandler = (result) => {
    history.push(`/digital_objects/${result.data.updateRights.digitalObject.id}/rights`);
  };

  const onSaveHandler = () => {
    const cleanRights = removeEmptyKeys(removeTypename(rights));
    const variables = { input: { id, rights: cleanRights, optimisticLockToken } };

    return updateRights({ variables });
  };

  if (!hasAssetRights) {
    delete rights.copyright_status_override;
  }

  const findFieldConfig = (stringKey) => fieldConfiguration.find((c) => c.stringKey === stringKey);

  if (fieldConfiguration.length === 0) return (<p>Rights field configuration missing.</p>);

  return (
    <Form className="mb-3">
      <GraphQLErrors errors={updateError} />
      <ErrorList errors={userErrors.map((userError) => (`${userError.message} (path=${userError.path.join('/')})`))} />

      <FieldGroupArray
        value={rights.asset_access_restriction}
        defaultValue={defaultAssetRights.asset_access_restriction[0]}
        dynamicFieldGroup={findFieldConfig('asset_access_restriction')}
        onChange={(v) => setRights('asset_access_restriction', v)}
      />

      {
        hasAssetRights && (
          <FieldGroupArray
            value={rights.copyright_status_override}
            defaultValue={defaultAssetRights.copyright_status_override[0]}
            dynamicFieldGroup={findFieldConfig('copyright_status_override')}
            onChange={(v) => setRights('copyright_status_override', v)}
          />
        )
      }
      <FormButtons
        formType="edit"
        cancelTo={`/digital_objects/${id}/rights`}
        onSave={onSaveHandler}
        onSaveSuccess={saveSuccessHandler}
      />
    </Form>
  );
}

export default AssetRightsForm;

AssetRightsForm.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
  fieldConfiguration: PropTypes.objectOf(PropTypes.any).isRequired,
};
