import React, { useState } from 'react';
import { Alert, Form, Button } from 'react-bootstrap';
import { startCase } from 'lodash';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import ContextualNavbar from '../shared/ContextualNavbar';
import SelectInput from '../shared/forms/inputs/SelectInput';
import InputGroup from '../shared/forms/InputGroup';
import uploadFile from '../../graphql/fileUploads';
import FileInput from '../shared/forms/inputs/FileInput';
import { createBatchImportMutation, validateBatchImportMutation, startBatchImportMutation } from '../../graphql/batchImports';
import GraphQLErrors from '../shared/GraphQLErrors';
import ErrorList from '../shared/ErrorList';
import SubmitButton from '../shared/forms/buttons/SubmitButton';

const priorities = ['low', 'medium', 'high'];

function BatchImportNew() {
  const uploadUrl = '/api/v1/uploads';
  const history = useHistory();
  const [priority, setPriority] = useState('medium');
  const [file, setFile] = useState(null);
  const [uploadPercentage, setUploadPercentage] = useState(0);
  const [validationResult, setValidationResult] = useState(null);
  const [validationErrors, setValidationErrors] = useState([]);

  const [createBatchImport, { error: createError }] = useMutation(createBatchImportMutation);
  const [validateBatchImport, { error: validateError }] = useMutation(validateBatchImportMutation);
  const [startBatchImport, { error: startError }] = useMutation(startBatchImportMutation);

  const onProgress = (percentageComplete) => {
    setUploadPercentage(percentageComplete);
  };

  const performUpload = (callback) => {
    if (file == null) return;
    uploadFile(file, uploadUrl, onProgress).then((blobAttributes) => {
      callback(blobAttributes);
    });
  };

  const submitBatchImportCreation = (e) => {
    e.preventDefault();
    performUpload((blobAttributes) => {
      const createVariables = { input: { priority, signedBlobId: blobAttributes.signed_id } };
      createBatchImport({ variables: createVariables }).then((createResponse) => {
        const { data: { createBatchImport: { isValid, errors } } } = createResponse;
        if (isValid) {
          const startVariables = {
            input: {
              id: createResponse.data.createBatchImport.batchImport.id,
            },
          };
          startBatchImport({ variables: startVariables }).then((startResponse) => {
            history.push(`/batch_imports/${startResponse.data.startBatchImport.batchImport.id}`);
          });
        } else {
          setValidationResult(isValid);
          setValidationErrors(errors);
        }
      });
    });
  };

  const submitBatchImportValidation = (e) => {
    e.preventDefault();
    performUpload((blobAttributes) => {
      const variables = { input: { signedBlobId: blobAttributes.signed_id } };
      validateBatchImport({ variables }).then((response) => {
        const { data: { validateBatchImport: { isValid, errors } } } = response;
        setValidationResult(isValid);
        setValidationErrors(errors);
      });
    });
  };

  const onFileChange = (selectedFile) => {
    setFile(selectedFile);
  };

  return (
    <>
      <ContextualNavbar
        title="Create Batch Import"
        rightHandLinks={[
          { link: '/batch_imports', label: 'Back to All Batch Imports' },
        ]}
      />

      <GraphQLErrors errors={createError || validateError || startError} />

      <div className="m-2">
        <Alert variant="info">
          Important Note: Please avoid using Microsoft Excel for CSV editing,
          imports, or exports. Excel doesn&apos;t handle UTF-8 properly.
        </Alert>
        {validationResult && (<Alert variant="success">This Batch Import appears to be valid.</Alert>) }
        <ErrorList errors={validationErrors} />
        <Form>
          <FileInput
            className="mb-2"
            onFileChange={onFileChange}
            uploadPercentage={uploadPercentage}
          />
          <InputGroup>
            <SelectInput
              sm={12}
              value={priority}
              onChange={setPriority}
              options={priorities.map(p => ({ value: p.toUpperCase(), label: `Priority: ${startCase(p)}` }))}
            />
          </InputGroup>

          <SubmitButton formType="new" onClick={submitBatchImportCreation} />
          <Button
            variant="secondary"
            className="ml-3"
            onClick={submitBatchImportValidation}
          >
            Validate
          </Button>
        </Form>
      </div>
    </>
  );
}

export default BatchImportNew;
