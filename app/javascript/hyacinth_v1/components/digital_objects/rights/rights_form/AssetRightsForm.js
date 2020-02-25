import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { merge } from 'lodash';
import { useMutation } from '@apollo/react-hooks';

import FormButtons from '../../../shared/forms/FormButtons';
import CopyrightStatus from './subsections/CopyrightStatus';
import AccessCondition from './subsections/AccessCondition';
import { defaultAssetRights } from './defaultRights';
import { useHash } from './rightsHooks';
import { updateAssetRightsMutation } from '../../../../graphql/digitalObjects';
import GraphQLErrors from '../../../shared/GraphQLErrors';
import { removeTypename, removeEmptyKeys } from '../../../../utils/deepKeyRemove';

function AssetRightsForm(props) {
  const {
    digitalObject: {
      id,
      primaryProject: { hasAssetRights },
      rights: initialRights,
    },
  } = props;

  const history = useHistory();

  const [rights, setRights] = useHash(merge({}, defaultAssetRights, removeEmptyKeys(initialRights)));

  const [updateRights, { error: updateError }] = useMutation(updateAssetRightsMutation);

  const onSubmitHandler = () => {
    const cleanRights = removeEmptyKeys(removeTypename(rights));
    const variables = { input: merge({ id }, cleanRights) };

    return updateRights({ variables }).then(res => history.push(`/digital_objects/${res.data.updateAssetRights.asset.id}/rights`));
  };

  const { copyrightStatusOverride, restrictionOnAccess } = rights;

  if (!hasAssetRights) {
    delete rights.copyrightStatusOverride;
  }


  return (
    <Form className="mb-3">
      <GraphQLErrors errors={updateError} />

      <AccessCondition
        values={restrictionOnAccess}
        onChange={v => setRights('restrictionOnAccess', v)}
      />
      {
        hasAssetRights && (
          <CopyrightStatus
            title="Asset Copyright Status Override"
            values={copyrightStatusOverride}
            onChange={v => setRights('copyrightStatusOverride', v)}
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
