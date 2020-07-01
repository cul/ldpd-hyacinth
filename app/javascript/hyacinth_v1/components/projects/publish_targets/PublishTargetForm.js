import React, { useState } from 'react';
import { Form, Collapse } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';
import { lowerCase } from 'lodash';

import InputGroup from '../../shared/forms/InputGroup';
import Label from '../../shared/forms/Label';
import FormButtons from '../../shared/forms/FormButtons';
import NumberInput from '../../shared/forms/inputs/NumberInput';
import TextInput from '../../shared/forms/inputs/TextInput';
import SelectInput from '../../shared/forms/inputs/SelectInput';
import Checkbox from '../../shared/forms/inputs/Checkbox';
import {
  createPublishTargetMutation,
  updatePublishTargetMutation,
  deletePublishTargetMutation,
} from '../../../graphql/publishTargets';
import GraphQLErrors from '../../shared/GraphQLErrors';

const publishTargetTypes = ['PRODUCTION', 'STAGING'];

function PublishTargetForm({ projectStringKey, publishTarget, formType }) {
  const [type, setType] = useState(publishTarget ? publishTarget.type : '');
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
        projectStringKey, type, publishUrl, apiKey, isAllowedDoiTarget, doiPriority,
      },
    };

    switch (formType) {
      case 'new':
        return createPublishTarget({ variables }).then((res) => {
          history.push(`/projects/${projectStringKey}/publish_targets/${lowerCase(res.data.createPublishTarget.publishTarget.type)}/edit`);
        });
      case 'edit':
        return updatePublishTarget({ variables }).then(() => {
          history.push(`/projects/${projectStringKey}/publish_targets`);
        });
      default:
        return null;
    }
  };

  const onDeleteHandler = (e) => {
    e.preventDefault();

    const variables = { input: { projectStringKey, type: publishTarget.type } };

    deletePublishTarget({ variables }).then(() => {
      history.push(`/projects/${projectStringKey}/publish_targets`);
    });
  };

  return (
    <Form onSubmit={onSaveHandler}>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <InputGroup>
        <Label>Type</Label>
        <SelectInput
          value={type}
          options={publishTargetTypes.map(t => ({ label: lowerCase(t), value: t }))}
          onChange={v => setType(v)}
          disabled={formType === 'edit'}
        />
      </InputGroup>

      <InputGroup>
        <Label>Publish URL</Label>
        <TextInput value={publishUrl} onChange={v => setPublishUrl(v)} />
      </InputGroup>

      <InputGroup>
        <Label>API Key</Label>
        <TextInput value={apiKey} onChange={v => setApiKey(v)} />
      </InputGroup>

      <InputGroup>
        <Label>Allowed to be set as DOI target?</Label>
        <Checkbox value={isAllowedDoiTarget} onChange={v => setIsAllowedDoiTarget(v)} />
      </InputGroup>

      <Collapse in={isAllowedDoiTarget}>
        <div>
          <InputGroup>
            <Label>DOI Priority</Label>
            <NumberInput value={doiPriority} onChange={v => setDoiPriority(v)} />
          </InputGroup>
        </div>
      </Collapse>

      <FormButtons
        formType={formType}
        cancelTo={`/projects/${projectStringKey}/publish_targets`}
        onSave={onSaveHandler}
        onDelete={onDeleteHandler}
      />
    </Form>
  );
}

export default PublishTargetForm;
