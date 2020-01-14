import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import uploadFile from '../../../graphql/file_uploads';
import { createAssetMutation } from '../../../graphql/assets';

function AssetNew(props) {
  const { parentId, inputId, refetch } = props;
  const [createAsset] = useMutation(createAssetMutation);

  const onChange = (event) => {
    const {
      target: {
        validity,
        files: [file],
      },
    } = event;
    if (!validity.valid) return false;
    function resetFileInput() {
      document.getElementById(inputId).value = '';
    }
    const url = `/api/v1/digital_objects/${parentId}/uploads`;

    return uploadFile(file, url)
      .then(blobAttributes => createAsset(
        {
          variables: {
            input: {
              signedBlobId: blobAttributes.signed_id,
              parentId,
            },
          },
          update: refetch,
        },
      ))
      .then(resetFileInput);
  };
  return (
    <Form>
      <input id={inputId} type="file" required onChange={onChange} parentid={parentId} direct_upload="true" />
    </Form>
  );
}

AssetNew.propTypes = {
  parentId: PropTypes.string.isRequired,
  inputId: PropTypes.string.isRequired,
  refetch: PropTypes.func.isRequired,
};

AssetNew.randomInputId = () => `input-${String.toString(Math.random()).replace('.', '')}`;

export default AssetNew;
