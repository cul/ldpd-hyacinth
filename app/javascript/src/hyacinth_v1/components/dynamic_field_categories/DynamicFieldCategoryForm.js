import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import FormButtons from '../shared/forms/FormButtons';
import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import NumberInput from '../shared/forms/inputs/NumberInput';
import TextInput from '../shared/forms/inputs/TextInput';
import {
  createDynamicFieldCategoryMutation,
  updateDynamicFieldCategoryMutation,
  deleteDynamicFieldCategoryMutation,
} from '../../graphql/dynamicFieldCategories';
import GraphQLErrors from '../shared/GraphQLErrors';

function DynamicFieldCategoryForm(props) {
  const { formType, dynamicFieldCategory } = props;

  const history = useHistory();

  const [displayLabel, setDisplayLabel] = useState(dynamicFieldCategory ? dynamicFieldCategory.displayLabel : '');
  const [sortOrder, setSortOrder] = useState(
    dynamicFieldCategory ? dynamicFieldCategory.sortOrder : null,
  );

  const [createDynamicFieldCategory, { error: createError }] = useMutation(
    createDynamicFieldCategoryMutation,
  );
  const [updateDynamicFieldCategory, { error: updateError }] = useMutation(
    updateDynamicFieldCategoryMutation,
  );
  const [deleteDynamicFieldCategory, { error: deleteError }] = useMutation(
    deleteDynamicFieldCategoryMutation,
  );

  const saveSuccessHandler = (result) => {
    if (result.data.createDynamicFieldCategory) {
      history.push(`/dynamic_field_categories/${result.data.createDynamicFieldCategory.dynamicFieldCategory.id}/edit`);
    }
  };
  const deleteSuccessHandler = () => {
    history.push('/dynamic_fields');
  };

  const onSaveHandler = () => {
    const variables = { input: { displayLabel, sortOrder } };

    switch (formType) {
      case 'new':
        return createDynamicFieldCategory({ variables });
      case 'edit':
        variables.input.id = dynamicFieldCategory.id;
        return updateDynamicFieldCategory({ variables });
      default:
        return null;
    }
  };

  const onDeleteHandler = (event) => {
    event.preventDefault();

    const variables = { input: { id: dynamicFieldCategory.id } };

    return deleteDynamicFieldCategory({ variables });
  };

  const cancelTo = '/dynamic_fields';

  return (
    <Form>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <InputGroup>
        <Label>Display Label</Label>
        <TextInput value={displayLabel} onChange={setDisplayLabel} />
      </InputGroup>

      <InputGroup>
        <Label>Sort Order</Label>
        <NumberInput value={sortOrder} onChange={setSortOrder} />
      </InputGroup>

      <FormButtons
        formType={formType}
        cancelTo={cancelTo}
        onDelete={onDeleteHandler}
        onDeleteSuccess={deleteSuccessHandler}
        onSave={onSaveHandler}
        onSaveSuccess={saveSuccessHandler}
      />
    </Form>
  );
}

DynamicFieldCategoryForm.defaultProps = {
  dynamicFieldCategory: null,
};

DynamicFieldCategoryForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  dynamicFieldCategory: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    displayLabel: PropTypes.string,
    sortOrder: PropTypes.number,
  }),
};

export default DynamicFieldCategoryForm;
