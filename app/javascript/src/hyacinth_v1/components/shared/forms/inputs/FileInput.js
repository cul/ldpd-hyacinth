import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { ProgressBar, Button } from 'react-bootstrap'

function FileInput(props) {
  const [lastSelectedFileName, setLastSelectedFileName] = useState(null);

  const {
    promptForNewFileAfterUpload, onFileChange, uploadPercentage, ...rest
  } = props;

  const onChange = (event) => {
    const { target: { validity, files: [file] } } = event;
    if (!validity.valid) {
      setLastSelectedFileName(null);
      return false;
    }
    setLastSelectedFileName(file.name);
    onFileChange(file);

    // If the input's value isn't cleared, then onChange won't
    // fire again if the same file is dropped on again.
    event.target.value = '';
  };

  const uploadAreaContent = () => {
    if (lastSelectedFileName) {
      if (uploadPercentage === 0 || (uploadPercentage === 100 && !promptForNewFileAfterUpload)) {
        return (
          <>
            <strong>{`Selected file: ${lastSelectedFileName}`}</strong>
            <br />
            or
            <br />
            <Button className="mt-1" size="sm">
              Select a different file
            </Button>
          </>
        );
      }

      if (uploadPercentage === 100) {
        return (
          <>
            Drop a file here
            <br />
            or
            <br />
            <Button className="mt-1" size="sm">
              Select a file
            </Button>
          </>
        );
      }

      return (
        <>
          <strong>{`Selected file: ${lastSelectedFileName}`}</strong>
          <br />
          Uploading...
        </>
      );
    }

    return (
      <>
        Drop a file here
        <br />
        or
        <br />
        <Button className="mt-1" size="sm">
          Select a file
        </Button>
      </>
    );
  };

  return (
    <div
      {...rest}
    >
      <div
        className="upload-drop-zone w-100"
        style={{
          position: 'relative',
          padding: '1em',
          border: '2px dashed #ccc',
          overflow: 'hidden',
          textAlign: 'center',
          color: '#777',
        }}
        {...rest}
      >
        {uploadAreaContent()}
        <input
          style={{
            position: 'absolute',
            top: 0,
            right: 0,
            opacity: 0,
            fontSize: '300px',
            // The line below conditionally hides the input,
            // making it non-clickable uncer certain conditions.
            display: (uploadPercentage === 0 || uploadPercentage === 100 ? 'inherit' : 'none'),
          }}
          type="file"
          required
          onChange={onChange}
          direct_upload="true"
        />
      </div>
      <ProgressBar
        className="mt-1"
        variant="info"
        now={uploadPercentage}
        max={100}
        label={uploadPercentage === 100 ? 'Upload Complete!' : ''}
      />
    </div>
  );
}

FileInput.defaultProps = {
  uploadPercentage: 0,
  promptForNewFileAfterUpload: false
};

FileInput.propTypes = {
  onFileChange: PropTypes.func.isRequired,
  uploadPercentage: PropTypes.number,
  promptForNewFileAfterUpload: PropTypes.bool,
};

export default FileInput;
