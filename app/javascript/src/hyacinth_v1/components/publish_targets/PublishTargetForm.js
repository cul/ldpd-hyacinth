import React, { useState } from 'react';
import { Form, Collapse } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import FormButtons from '../shared/forms/FormButtons';
import NumberInput from '../shared/forms/inputs/NumberInput';
import TextInput from '../shared/forms/inputs/TextInput';
import Checkbox from '../shared/forms/inputs/Checkbox';
import {
  createPublishTargetMutation,
  updatePublishTargetMutation,
  deletePublishTargetMutation,
} from '../../graphql/publishTargets';
import GraphQLErrors from '../shared/GraphQLErrors';

function PublishTargetForm({ publishTarget, formType }) {
  const [stringKey, setStringKey] = useState(publishTarget ? publishTarget.stringKey : '');
  const [publishUrl, setPublishUrl] = useState(publishTarget ? publishTarget.publishUrl : '');
  const [apiKey, setApiKey] = useState(publishTarget ? publishTarget.apiKey : '');
  const [isAllowedDoiTarget, setIsAllowedDoiTarget] = useState(publishTarget ? publishTarget.isAllowedDoiTarget : false);
  const [doiPriority, setDoiPriority] = useState(publishTarget ? publishTarget.doiPriority : 100);

  const [createPublishTarget, { error: createError }] = useMutation(createPublishTargetMutation);
  const [updatePublishTarget, { error: updateError }] = useMutation(updatePublishTargetMutation);
  const [deletePublishTarget, { error: deleteError }] = useMutation(deletePublishTargetMutation);

  const history = useHistory();

  const onSaveHandler = () => {
    const variables = {
      input: {
        stringKey, publishUrl, apiKey, isAllowedDoiTarget, doiPriority,
      },
    };

    return formType === 'new' ? createPublishTarget({ variables }) : updatePublishTarget({ variables });
  };

  const saveSuccessHandler = (result) => {
    if (formType === 'new') {
      history.push(`/publish_targets/${result.data.createPublishTarget.publishTarget.stringKey}`);
    } else {
      history.push(`/publish_targets/${result.data.updatePublishTarget.publishTarget.stringKey}`);
    }
  };

  const onDeleteHandler = (e) => {
    e.preventDefault();

    const variables = { input: { stringKey } };

    return deletePublishTarget({ variables });
  };

  const deleteSuccessHandler = () => {
    history.push('/publish_targets');
  };

  return (
    <Form onSubmit={onSaveHandler}>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <InputGroup>
        <Label>String Key</Label>
        <TextInput value={stringKey} onChange={(v) => setStringKey(v)} />
      </InputGroup>

      <InputGroup>
        <Label>Publish URL</Label>
        <TextInput value={publishUrl} onChange={(v) => setPublishUrl(v)} />
      </InputGroup>

      <InputGroup>
        <Label>API Key</Label>
        <TextInput value={apiKey} onChange={(v) => setApiKey(v)} />
      </InputGroup>

      <InputGroup>
        <Label>Allowed to be set as DOI target?</Label>
        <Checkbox value={isAllowedDoiTarget} onChange={(v) => setIsAllowedDoiTarget(v)} />
      </InputGroup>

      <Collapse in={isAllowedDoiTarget}>
        <div>
          <InputGroup>
            <Label>DOI Priority</Label>
            <NumberInput value={doiPriority} onChange={(v) => setDoiPriority(v)} />
          </InputGroup>
        </div>
      </Collapse>

      <FormButtons
        formType={formType}
        cancelTo={formType === 'new' ? '/publish_targets' : `/publish_targets/${publishTarget.stringKey}`}
        onSave={onSaveHandler}
        onDeleteSuccess={deleteSuccessHandler}
        onDelete={onDeleteHandler}
        onSaveSuccess={saveSuccessHandler}
      />
    </Form>
  );
}

export default PublishTargetForm;
