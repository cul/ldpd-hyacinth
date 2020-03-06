import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';

import { createAssetMutation } from '../../../graphql/assets';
import FileInput from '../../shared/forms/inputs/FileInput';

function AssetNew(props) {
  const { parentId, refetch } = props;
  const [createAsset] = useMutation(createAssetMutation);

  const saveBlobToRecord = blobAttributes => createAsset(
    {
      variables: {
        input: {
          signedBlobId: blobAttributes.signed_id,
          parentId,
        },
      },
      update: refetch,
    },
  );

  return (
    <Form>
      <FileInput saveBlobToRecord={saveBlobToRecord} />
    </Form>
  );
}

AssetNew.propTypes = {
  parentId: PropTypes.string.isRequired,
  refetch: PropTypes.func.isRequired,
};

export default AssetNew;
