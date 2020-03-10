import React, { useState } from 'react';
import PropTypes from 'prop-types';

import uploadFile from '../../../../graphql/fileUploads';

function FileInput(props) {
  const randomInputId = () => `input-${Math.random().toString().replace('.', '')}`;

  const [inputId] = useState(randomInputId);
  const { onUpload, resetAfterUpload } = props;

  const onChange = (event) => {
    const {
      target: {
        validity,
        files: [file],
      },
    } = event;
    if (!validity.valid) return false;

    function resetFileInput() {
      if (resetAfterUpload) {
        document.getElementById(inputId).value = '';
      }
    }

    const url = '/api/v1/uploads';

    return uploadFile(file, url)
      .then(blobAttributes => onUpload(blobAttributes).then(resetFileInput()));
  };

  return (
    <input
      id={inputId}
      type="file"
      required
      onChange={onChange}
      direct_upload="true"
    />
  );
}

FileInput.defaultProps = {
  resetAfterUpload: true,
};

FileInput.propTypes = {
  onUpload: PropTypes.func.isRequired,
  resetAfterUpload: PropTypes.bool,
};

export default FileInput;
