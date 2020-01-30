import React, { useState } from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { Form } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { merge } from 'lodash';

import keyTransformer from '../../../../util/keyTransformer';
import { digitalObject as digitalObjectApi } from '../../../../util/hyacinth_api';
import ContextualNavbar from '../../../layout/ContextualNavbar';
import FormButtons from '../../../ui/forms/FormButtons';
import CopyrightStatus from './subsections/CopyrightStatus';
import AccessCondition from './subsections/AccessCondition';
import { defaultAssetRights } from './defaultAssetRights';

const useHash = (initialHash) => {
  const [hash, setHash] = useState(initialHash);

  const setHashViaKey = (key, value) => setHash(produce(hash, (draft) => { draft[key] = value; }));

  return [hash, setHashViaKey];
};

function AssetRightsForm(props) {
  const { digitalObject: { id, primaryProject: { hasAssetRights }, rights: initialRights } } = props;
  const history = useHistory();

  const camelizedInitialRights = keyTransformer.deepCamelCase(initialRights);
  const [rights, setRights] = useHash(merge({}, defaultAssetRights(), camelizedInitialRights));

  const onSubmitHandler = () => {
    return digitalObjectApi.rights.update(
      id,
      { digitalObject: { rights: keyTransformer.deepSnakeCase(rights) } },
    ).then(res => history.push(`/digital_objects/${res.data.digitalObject.uid}/rights`));
  };

  const { copyrightStatusOverride, restrictionOnAccess } = rights;
  let copyrightForm;
  if (hasAssetRights) {
    copyrightForm = <CopyrightStatus
          title="Asset Copyright Status Override"
          value={copyrightStatusOverride}
          onChange={v => setRights('copyrightStatusOverride', v)}
        />;
  } else {
    copyrightForm = <></>;
  }

  return (
    <>
      <ContextualNavbar
        title="Editing Asset Rights"
        rightHandLinks={[
          { link: '/digital_objects', label: 'Cancel' },
        ]}
      />

      <Form className="mb-3">
        <AccessCondition
          value={restrictionOnAccess}
          onChange={v => setRights('restrictionOnAccess', v)}
        />
        {copyrightForm}
        <FormButtons
          formType="edit"
          cancelTo={`/digital_objects/${id}/rights`}
          onSave={onSubmitHandler}
        />
      </Form>

    </>
  );

}

export default AssetRightsForm;

AssetRightsForm.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
};
