import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form } from 'react-bootstrap';
import { gql } from 'apollo-boost';
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

  const onSaveHandler = () => {
    const variables = { input: { projectStringKey, displayLabel } };

    switch (formType) {
      case 'new':
        return createFieldSet({ variables }).then((res) => {
          history.push(`/projects/${projectStringKey}/field_sets/${res.data.createFieldSet.fieldSet.id}/edit`);
        });
      case 'edit':
        variables.input.id = fieldSet.id;
        return updateFieldSet({ variables }).then(() => {
          history.push(`/projects/${projectStringKey}/field_sets/`);
        });
      default:
        return null;
    }
  };

  const onDeleteHandler = (event) => {
    event.preventDefault();

    deleteFieldSet({
      variables: {
        input: { projectStringKey, id: fieldSet.id },
      },
    }).then(() => history.push(`/projects/${projectStringKey}/field_sets`));
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
