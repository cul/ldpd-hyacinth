import React, { useState } from 'react';
import PropTypes from 'prop-types';

import uploadFile from '../../../../graphql/fileUploads';

function FileInput(props) {
  const randomInputId = () => `input-${Math.random().toString().replace('.', '')}`;

  const [inputId] = useState(randomInputId);
  const { saveBlobToRecord } = props;

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

    const url = '/api/v1/uploads';

    return uploadFile(file, url)
      .then(blobAttributes => saveBlobToRecord(blobAttributes).then(resetFileInput()));
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

FileInput.propTypes = {
  saveBlobToRecord: PropTypes.func.isRequired,
};

export default FileInput;
