import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Row, Form, Collapse } from 'react-bootstrap';
import { startCase } from 'lodash';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import FormButtons from '../shared/forms/FormButtons';
import TextInput from '../shared/forms/inputs/TextInput';
import NumberInput from '../shared/forms/inputs/NumberInput';
import SelectInput from '../shared/forms/inputs/SelectInput';
import VocabularySelect from '../shared/forms/inputs/selects/VocabularySelect';
import Checkbox from '../shared/forms/inputs/Checkbox';
import {
  createDynamicFieldMutation,
  updateDynamicFieldMutation,
  deleteDynamicFieldMutation,
} from '../../graphql/dynamicFields';
import GraphQLErrors from '../shared/GraphQLErrors';
import JSONInput from '../shared/forms/inputs/lazyJSONInput';

const fieldTypes = [
  'string', 'textarea', 'integer', 'boolean', 'select', 'date', 'controlled_term',
];

function DynamicFieldForm(props) {
  const { formType, dynamicField, defaultValues } = props;

  const history = useHistory();

  const [stringKey, setStringKey] = useState((dynamicField && dynamicField.stringKey) || '');
  const [displayLabel, setDisplayLabel] = useState((dynamicField && dynamicField.displayLabel) || '');
  const [fieldType, setFieldType] = useState((dynamicField && dynamicField.fieldType) || 'string');
  const [sortOrder, setSortOrder] = useState((dynamicField && dynamicField.sortOrder) || null);
  const [isFacetable, setIsFacetable] = useState((dynamicField && dynamicField.isFacetable) || false);
  const [filterLabel, setFilterLabel] = useState((dynamicField && dynamicField.filterLabel) || '');
  const [controlledVocabulary, setControlledVocabulary] = useState((dynamicField && dynamicField.controlledVocabulary) || '');
  const [selectOptions, setSelectOptions] = useState((dynamicField && dynamicField.selectOptions) || '{}');
  const [
    isKeywordSearchable,
    setIsKeywordSearchable,
  ] = useState(dynamicField ? dynamicField.isKeywordSearchable : false);
  const [
    isTitleSearchable,
    setIsTitleSearchable,
  ] = useState(dynamicField ? dynamicField.isTitleSearchable : false);
  const [
    isIdentifierSearchable,
    setIsIdentifierSearchable,
  ] = useState(dynamicField ? dynamicField.isIdentifierSearchable : false);
  const [
    dynamicFieldGroupId,
  ] = useState(dynamicField ? dynamicField.dynamicFieldGroupId : defaultValues.dynamicFieldGroupId);

  const [createDynamicField, { error: createError }] = useMutation(createDynamicFieldMutation);
  const [updateDynamicField, { error: updateError }] = useMutation(updateDynamicFieldMutation);
  const [deleteDynamicField, { error: deleteError }] = useMutation(deleteDynamicFieldMutation);

  const onSave = () => {
    const variables = {
      input: {
        displayLabel,
        fieldType,
        sortOrder,
        isFacetable,
        filterLabel,
        controlledVocabulary,
        selectOptions,
        isKeywordSearchable,
        isTitleSearchable,
        isIdentifierSearchable,
      },
    };

    switch (formType) {
      case 'new':
        variables.input.stringKey = stringKey;
        variables.input.dynamicFieldGroupId = dynamicFieldGroupId;

        return createDynamicField({ variables }).then((res) => {
          const { dynamicField: { id: newId } } = res.data.createDynamicField;

          history.push(`/dynamic_fields/${newId}/edit`);
        });
      case 'edit':
        variables.input.id = dynamicField.id;
        return updateDynamicField({ variables });
      default:
        return null;
    }
  };

  const onDeleteHandler = (event) => {
    event.preventDefault();

    const variables = { input: { id: dynamicField.id } };

    deleteDynamicField({ variables }).then(() => history.push('/dynamic_fields'));
  };

  const onFieldTypeSelect = (newFieldType) => {
    if (newFieldType !== 'controlled_term') setControlledVocabulary('');
    if (newFieldType === 'textarea') setIsFacetable(false);

    setFieldType(newFieldType);
  };

  const showControlledVocabularySelector = (fieldType === 'controlled_term');
  const showSelectOptionsInput = (fieldType === 'select');
  const showIsFacetableCheckbox = (fieldType !== 'textarea');

  return (
    <Form>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <InputGroup>
        <Label>String Key</Label>
        <TextInput value={stringKey} onChange={setStringKey} disabled={formType === 'edit'} />
      </InputGroup>

      <InputGroup>
        <Label>Display Label</Label>
        <TextInput value={displayLabel} onChange={setDisplayLabel} />
      </InputGroup>

      <InputGroup>
        <Label>Sort Order</Label>
        <NumberInput value={sortOrder} onChange={setSortOrder} />
      </InputGroup>

      <h4>Field Configuration</h4>

      <InputGroup as={Row}>
        <Label>Field Type</Label>
        <SelectInput
          value={fieldType}
          options={fieldTypes.map(t => ({ value: t, label: startCase(t) }))}
          onChange={onFieldTypeSelect}
        />
      </InputGroup>

      <Collapse in={showControlledVocabularySelector}>
        <div>
          <InputGroup>
            <Label>Controlled Vocabulary</Label>
            <VocabularySelect value={controlledVocabulary} onChange={setControlledVocabulary} />
          </InputGroup>
        </div>
      </Collapse>

      <Collapse in={showSelectOptionsInput}>
        <div>
          <InputGroup>
            <Label>Select Options</Label>
            <JSONInput
              value={selectOptions}
              onChange={setSelectOptions}
              height="100px"
              placeholder={'[{ "value": "", "label": "" }]'}
            />
          </InputGroup>
        </div>
      </Collapse>

      <h4>Searching/Facets</h4>
      <InputGroup>
        <Label>Filter Label</Label>
        <TextInput value={filterLabel} onChange={setFilterLabel} />
      </InputGroup>

      <Collapse in={showIsFacetableCheckbox}>
        <div>
          <InputGroup>
            <Label>Is Facetable?</Label>
            <Checkbox value={isFacetable} onChange={setIsFacetable} />
          </InputGroup>
        </div>
      </Collapse>

      <InputGroup>
        <Label>Include in:</Label>
        <Checkbox sm={3} lg={2} value={isKeywordSearchable} onChange={setIsKeywordSearchable} label="keyword search" />
        <Checkbox sm={3} lg={2} value={isTitleSearchable} onChange={setIsTitleSearchable} label="title search" />
        <Checkbox sm={3} lg={2} value={isIdentifierSearchable} onChange={setIsIdentifierSearchable} label="identifier search" />
      </InputGroup>

      <FormButtons
        formType={formType}
        cancelTo="/dynamic_fields"
        onDelete={onDeleteHandler}
        onSave={onSave}
      />
    </Form>
  );
}

DynamicFieldForm.defaultProps = {
  dynamicField: null,
  defaultValues: null,
};

DynamicFieldForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  dynamicField: PropTypes.shape({
    stringKey: PropTypes.string,
    displayLabel: PropTypes.string,
  }),
  defaultValues: PropTypes.shape({
    dynamicFieldGroupId: PropTypes.string.isRequired,
  }),
};

export default DynamicFieldForm;
