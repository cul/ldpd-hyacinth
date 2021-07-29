import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';
import produce from 'immer';

import InputGroup from '../../shared/forms/InputGroup';
import Label from '../../shared/forms/Label';
import TextInput from '../../shared/forms/inputs/TextInput';
import TextInputWithAddAndRemove from '../../shared/forms/inputs/TextInputWithAddAndRemove';
import SelectInput from '../../shared/forms/inputs/SelectInput';
import NumberInput from '../../shared/forms/inputs/NumberInput';
import ReadOnlyInput from '../../shared/forms/inputs/ReadOnlyInput';
import PlainText from '../../shared/forms/inputs/PlainText';
import FormButtons from '../../shared/forms/FormButtons';
import GraphQLErrors from '../../shared/GraphQLErrors';
import { createTermMutation, updateTermMutation, deleteTermMutation } from '../../../graphql/terms';

const types = ['EXTERNAL', 'LOCAL', 'TEMPORARY'];

const useCustomFields = (initialState) => {
  // Removing _typename from each hash.
  const cleanedInitialState = initialState.map(({ __typename, ...rest }) => (rest));

  const [customFields, setCustomFields] = useState(cleanedInitialState);

  const setCustomField = (field, value) => {
    const index = customFields.findIndex(f => f.field === field);

    if (index === -1) {
      setCustomFields(produce(draft => draft.push({ field, value })));
    } else {
      setCustomFields(produce((draft) => { draft[index].value = value; }));
    }
  };

  return [customFields, setCustomField];
};

function TermForm(props) {
  const {
    formType, small, vocabulary, term, cancelAction, submitAction,
  } = props;

  const [uri, setUri] = useState(term ? term.uri : '');
  const [prefLabel, setPrefLabel] = useState(term ? term.prefLabel : '');
  const [altLabels, setAltLabels] = useState(term ? term.altLabels : []);
  const [termType, setTermType] = useState(term ? term.termType : '');
  const [authority, setAuthority] = useState(term ? term.authority : '');
  const [customFields, setCustomField] = useCustomFields(term ? term.customFields : []);

  const history = useHistory();

  const [createTerm, { error: createError }] = useMutation(createTermMutation);
  const [updateTerm, { error: updateError }] = useMutation(updateTermMutation);
  const [deleteTerm, { error: deleteError }] = useMutation(deleteTermMutation);

  const onSuccessHandler = (result) => {
    const opResult = result.data.createTerm || result.data.updateTerm;
    const { term: { uri: newURI } } = opResult;

    if (submitAction) {
      submitAction(opResult.term);
    } else {
      history.push(`/controlled_vocabularies/${vocabulary.stringKey}/terms/${encodeURIComponent(newURI)}/edit`);
    }
  };

  const onSaveHandler = () => {
    const variables = {
      input: {
        vocabularyStringKey: vocabulary.stringKey,
        uri,
        prefLabel,
        altLabels,
        authority,
        customFields,
      },
    };

    switch (formType) {
      case 'new':
        variables.input.termType = termType;
        return createTerm({ variables });
      case 'edit':
        return updateTerm({ variables });
      default:
        return null;
    }
  };

  const onDeleteHandler = (event) => {
    event.preventDefault();
    const variables = { input: { vocabularyStringKey: vocabulary.stringKey, uri } };

    deleteTerm({ variables }).then(() => history.push(`/controlled_vocabularies/${vocabulary.stringKey}`));
  };

  const labelColWidth = small ? 4 : 2;
  const inputColWidth = small ? 8 : 10;

  return (
    <Form>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <InputGroup className="mb-2">
        <Label sm={labelColWidth}>Term Type</Label>
        {
          formType === 'new'
            ? <SelectInput sm={inputColWidth} value={termType} onChange={v => setTermType(v)} options={types.map(t => ({ label: t, value: t }))} />
            : <PlainText sm={inputColWidth} value={termType} />
        }
      </InputGroup>

      <InputGroup className="mb-2">
        <Label sm={labelColWidth}>URI</Label>

        {
          (() => {
            if (formType === 'edit') {
              return <PlainText value={uri} />;
            } else if (termType === 'external' || termType === '') {
              return <TextInput sm={inputColWidth} value={uri} onChange={v => setUri(v)} />;
            } else {
              return <ReadOnlyInput sm={inputColWidth} value={uri} />;
            }
          })()
        }
      </InputGroup>

      <InputGroup className="mb-2">
        <Label sm={labelColWidth}>Pref Label</Label>
        {
          termType === 'temporary' && formType !== 'new'
            ? <PlainText sm={inputColWidth} value={prefLabel} />
            : <TextInput sm={inputColWidth} value={prefLabel} onChange={v => setPrefLabel(v)} />
        }
      </InputGroup>

      {
        termType !== 'temporary' && (
          <InputGroup className="mb-2">
            <Label sm={labelColWidth}>Alternative Labels</Label>
            <TextInputWithAddAndRemove sm={inputColWidth} values={altLabels} onChange={v => setAltLabels(v)} />
          </InputGroup>
        )
      }

      <InputGroup className="mb-2">
        <Label sm={labelColWidth}>Authority</Label>
        <TextInput sm={inputColWidth} value={authority} onChange={v => setAuthority(v)} />
      </InputGroup>

      {
        vocabulary.customFieldDefinitions.map((definition) => {
          const { fieldKey, label, dataType } = definition;

          let field = '';
          const customField = customFields.find(element => element.field === fieldKey);
          const value = customField ? customField.value : '';

          switch (dataType) {
            case 'string':
              field = <TextInput sm={inputColWidth} value={value} onChange={v => setCustomField(fieldKey, v)} />;
              break;
            case 'integer':
              field = <NumberInput sm={inputColWidth} value={value} onChange={v => setCustomField(fieldKey, v)} />;
              break;
            default:
              field = '';
              break;
          }

          return (
            <InputGroup key={fieldKey}>
              <Label sm={labelColWidth}>{label}</Label>
              { field }
            </InputGroup>
          );
        })
      }

      <FormButtons
        formType={formType}
        cancelTo={`/controlled_vocabularies/${vocabulary.stringKey}`}
        cancelAction={cancelAction}
        onSave={onSaveHandler}
        onDelete={onDeleteHandler}
        onSuccess={onSuccessHandler}
      />
    </Form>
  );
}

TermForm.defaultProps = {
  term: null,
  small: false,
  cancelAction: null,
  submitAction: null,
};

TermForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  vocabulary: PropTypes.shape({
    stringKey: PropTypes.string,
  }).isRequired,
  term: PropTypes.shape({
    uri: PropTypes.string,
    prefLabel: PropTypes.string,
    authority: PropTypes.string,
  }),
  small: PropTypes.bool,
  cancelAction: PropTypes.func,
  submitAction: PropTypes.func,
};

export default TermForm;
