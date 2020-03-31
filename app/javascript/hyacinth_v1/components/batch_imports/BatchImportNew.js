import React, { useState } from 'react';
import { Alert, Form } from 'react-bootstrap';
import { startCase } from 'lodash';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import ContextualNavbar from '../shared/ContextualNavbar';
import SelectInput from '../shared/forms/inputs/SelectInput';
import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import FileInput from '../shared/forms/inputs/FileInput';
import { createBatchImportMutation } from '../../graphql/batchImports';
import GraphQLErrors from '../shared/GraphQLErrors';
import SubmitButton from '../shared/forms/buttons/SubmitButton';

const priorities = ['low', 'medium', 'high'];

function BatchImportNew() {
  const history = useHistory();
  const [priority, setPriority] = useState('low');
  const [signedBlobId, setSignedBlobId] = useState(null);

  const [createBatchImport, { error: createError }] = useMutation(createBatchImportMutation);

  const onSubmitHandler = (e) => {
    e.preventDefault();

    const variables = { input: { priority, signedBlobId } };

    createBatchImport({ variables }).then((res) => {
      history.push(`/batch_imports/${res.data.createBatchImport.batchImport.id}`);
    });
  };

  const onUpload = blobAttributes => setSignedBlobId(blobAttributes.signed_id);

  return (
    <>
      <ContextualNavbar
        title="Create Batch Import"
        rightHandLinks={[
          { link: '/batch_imports', label: 'Back to All Batch Imports' },
        ]}
      />

      <GraphQLErrors errors={createError} />

      <div className="m-2">
        <Alert variant="info">
          Important Note: Please avoid using Microsoft Excel for CSV editing,
          imports, or exports. Excel doesn&apos;t handle UTF-8 properly.
        </Alert>

        <Form>
          <InputGroup>
            <Label>Import CSV</Label>
            <FileInput onUpload={onUpload} resetAfterUpload={false} />
          </InputGroup>
          <InputGroup>
            <Label>Priority</Label>
            <SelectInput
              sm={4}
              value={priority}
              onChange={setPriority}
              options={priorities.map(p => ({ value: p, label: startCase(p) }))}
            />
          </InputGroup>

          {/* TODO: add validate button here */}
          <SubmitButton formType="new" onClick={onSubmitHandler} />
        </Form>
      </div>
    </>
  );
}

export default BatchImportNew;
