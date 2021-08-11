import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import TextInput from '../shared/forms/inputs/TextInput';
import PlainText from '../shared/forms/inputs/PlainText';
import Checkbox from '../shared/forms/inputs/Checkbox';
import FormButtons from '../shared/forms/FormButtons';
import { createVocabularyMutation, updateVocabularyMutation, deleteVocabularyMutation } from '../../graphql/vocabularies';
import GraphQLErrors from '../shared/GraphQLErrors';

function ControlledVocabularyForm(props) {
  const { formType, vocabulary } = props;

  const [label, setLabel] = useState(vocabulary ? vocabulary.label : '');
  const [stringKey, setStringKey] = useState(vocabulary ? vocabulary.stringKey : '');
  const [locked, setLocked] = useState(vocabulary ? vocabulary.locked : false);

  const history = useHistory();

  const [createVocabulary, { error: createError }] = useMutation(createVocabularyMutation);
  const [updateVocabulary, { error: updateError }] = useMutation(updateVocabularyMutation);
  const [deleteVocabulary, { error: deleteError }] = useMutation(deleteVocabularyMutation);

  const onSubmitHandler = () => {
    const variables = { input: { stringKey, label, locked } };

    switch (formType) {
      case 'new':
        return createVocabulary({ variables }).then((res) => {
          history.push(`/controlled_vocabularies/${res.data.createVocabulary.vocabulary.stringKey}/edit`);
        });
      case 'edit':
        return updateVocabulary({ variables });
      default:
        return null;
    }
  };

  const onDeleteHandler = (event) => {
    event.preventDefault();

    const variables = { input: { stringKey } };

    deleteVocabulary({ variables }).then(() => history.push('/controlled_vocabularies'));
  };

  return (
    <Form onSubmit={onSubmitHandler}>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <InputGroup>
        <Label>String Key</Label>
        {
          formType === 'new'
            ? <TextInput value={stringKey} onChange={v => setStringKey(v)} />
            : <PlainText value={stringKey} />
        }
      </InputGroup>

      <InputGroup>
        <Label>Label</Label>
        <TextInput
          value={label}
          onChange={v => setLabel(v)}
        />
      </InputGroup>

      <InputGroup>
        <Label>Locked</Label>
        <Checkbox value={locked} onChange={v => setLocked(v)} />
      </InputGroup>

      <FormButtons
        formType={formType}
        cancelTo={`/controlled_vocabularies/${stringKey}`}
        onDelete={onDeleteHandler}
        onSave={onSubmitHandler}
      />
    </Form>
  );
}

ControlledVocabularyForm.defaultProps = {
  vocabulary: null,
};

ControlledVocabularyForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  vocabulary: PropTypes.shape({
    stringKey: PropTypes.string,
    label: PropTypes.string,
  }),
};

export default ControlledVocabularyForm;
