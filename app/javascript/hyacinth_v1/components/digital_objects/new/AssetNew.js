import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';

import { createAssetMutation } from '../../../graphql/assets';
import AutoUploadFileInput from '../../shared/forms/inputs/AutoUploadFileInput';

function AssetNew(props) {
  const { parentId, refetch } = props;
  const [createAsset] = useMutation(createAssetMutation);

  const onUpload = blobAttributes => createAsset(
    {
      variables: {
        input: {
          fileLocation: `blob://${blobAttributes.signed_id}`,
          parentId,
        },
      },
      update: refetch,
    },
  );

  return (
    <Form>
      <AutoUploadFileInput onUpload={onUpload} promptForNewFileAfterUpload />
    </Form>
  );
}

AssetNew.propTypes = {
  parentId: PropTypes.string.isRequired,
  refetch: PropTypes.func.isRequired,
};

export default AssetNew;
