import React, { useState } from 'react';
import PropTypes from 'prop-types';

import uploadFile from '../../../../graphql/fileUploads';
import FileInput from './FileInput';

function AutoUploadFileInput(props) {
  const uploadUrl = '/api/v1/uploads';
  const [uploadPercentage, setUploadPercentage] = useState(0);
  const { onUpload, promptForNewFileAfterUpload, ...rest } = props;

  const onProgress = (percentageComplete) => {
    setUploadPercentage(percentageComplete);
  };

  const onFileChange = (file) => {
    return uploadFile(file, uploadUrl, onProgress).then((blobAttributes) => {
      onUpload(blobAttributes);
    });
  };

  return (
    <FileInput
      onFileChange={onFileChange}
      uploadPercentage={uploadPercentage}
      promptForNewFileAfterUpload={promptForNewFileAfterUpload}
      {...rest}
    />
  );
}

AutoUploadFileInput.defaultProps = {
  promptForNewFileAfterUpload: false,
};

AutoUploadFileInput.propTypes = {
  onUpload: PropTypes.func.isRequired,
  promptForNewFileAfterUpload: PropTypes.bool,
};

export default AutoUploadFileInput;
