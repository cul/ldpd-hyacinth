import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form } from 'react-bootstrap';
import gql from 'graphql-tag';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import FormButtons from '../../shared/forms/FormButtons';
import GraphQLErrors from '../../shared/GraphQLErrors';

const CREATE_FIELD_SET = gql`
  mutation CreateFieldSet($input: CreateFieldSetInput!) {
    createFieldSet(input: $input) {
      fieldSet {
        id
        displayLabel
      }
    }
  }
`;

const UPDATE_FIELD_SET = gql`
  mutation UpdateFieldSet($input: UpdateFieldSetInput!) {
    updateFieldSet(input: $input) {
      fieldSet {
        id
        displayLabel
      }
    }
  }
`;

const DELETE_FIELD_SET = gql`
  mutation DeleteFieldSet($input: DeleteFieldSetInput!) {
    deleteFieldSet(input: $input) {
      fieldSet {
        id
      }
    }
  }
`;

function FieldSetForm({ projectStringKey, fieldSet, formType }) {
  const [displayLabel, setDisplayLabel] = useState(fieldSet ? fieldSet.displayLabel : '');
  const [createFieldSet, { error: createError }] = useMutation(CREATE_FIELD_SET);
  const [updateFieldSet, { error: updateError }] = useMutation(UPDATE_FIELD_SET);
  const [deleteFieldSet, { error: deleteError }] = useMutation(DELETE_FIELD_SET);

  const history = useHistory();

  const onSuccessHandler = (result) => {
    if (result.data.createFieldSet) {
      history.push(`/projects/${projectStringKey}/field_sets/${result.data.createFieldSet.fieldSet.id}/edit`);
    } else if (result.data.deleteFieldSet) {
      history.push(`/projects/${projectStringKey}/field_sets`);
    }
  };

  const onSaveHandler = () => {
    const variables = { input: { projectStringKey, displayLabel } };

    switch (formType) {
      case 'new':
        return createFieldSet({ variables });
      case 'edit':
        variables.input.id = fieldSet.id;
        return updateFieldSet({ variables });
      default:
        return null;
    }
  };

  const onDeleteHandler = (event) => {
    event.preventDefault();

    return deleteFieldSet({
      variables: {
        input: { projectStringKey, id: fieldSet.id },
      },
    });
  };

  return (
    <Form onSubmit={onSaveHandler}>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <Form.Group as={Row}>
        <Form.Label column sm={2}>Display Label</Form.Label>
        <Col sm={10}>
          <Form.Control
            type="text"
            name="displayLabel"
            value={displayLabel}
            onChange={e => setDisplayLabel(e.target.value)}
          />
        </Col>
      </Form.Group>

      <FormButtons
        formType={formType}
        cancelTo={`/projects/${projectStringKey}/field_sets`}
        onDelete={onDeleteHandler}
        onSave={onSaveHandler}
        onSuccess={onSuccessHandler}
      />
    </Form>
  );
}

FieldSetForm.defaultProps = {
  fieldSet: null,
};

FieldSetForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  projectStringKey: PropTypes.string.isRequired,
  fieldSet: PropTypes.shape({
    id: PropTypes.string.isRequired,
    displayLabel: PropTypes.string.isRequired,
  }),
};

export default FieldSetForm;
