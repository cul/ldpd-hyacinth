import React, { useState } from 'react';
import { useMutation, useQuery } from '@apollo/react-hooks';
import PropTypes from 'prop-types';
import produce from 'immer';
import { merge } from 'lodash';
import { useHistory } from 'react-router-dom';

import FieldGroupArray from './FieldGroupArray';
import FormButtons from '../../shared/forms/FormButtons';
import GraphQLErrors from '../../shared/GraphQLErrors';
import ErrorList from '../../shared/ErrorList';
import InputGroup from '../../shared/forms/InputGroup';
import TextInputWithAddAndRemove from '../../shared/forms/inputs/TextInputWithAddAndRemove';
import { createDigitalObjectMutation, updateDescriptiveMetadataMutation } from '../../../graphql/digitalObjects';
import { getEnabledDynamicFieldsQuery } from '../../../graphql/projects/enabledDynamicFields';
import { getDynamicFieldGraphQuery } from '../../../graphql/dynamicFieldCategories';

const defaultFieldValue = {
  string: '',
  textarea: '',
  integer: null,
  boolean: false,
  select: '',
  date: '',
  controlled_term: {},
};

const DynamicFieldCategory = (props) => {
  const { category, onChange, descriptiveMetadata, defaultFieldData } = props;
  const { displayLabel, children } = category;
  const changeHandler = (sk) => {
    const stringKey = sk;
    return (v) => {
      return onChange(stringKey, v);
    };
  };
  return (
    <div key={displayLabel}>
      <h4 className="text-orange">{displayLabel}</h4>
      {
        children.map(fieldGroup => (
          <FieldGroupArray
            key={`array_${fieldGroup.stringKey}`}
            dynamicFieldGroup={fieldGroup}
            value={descriptiveMetadata[fieldGroup.stringKey]}
            defaultValue={defaultFieldData[fieldGroup.stringKey][0]}
            onChange={changeHandler(fieldGroup.stringKey)}
          />
        ))
      }
    </div>
  );
};

function MetadataForm(props) {
  const { digitalObject, formType } = props;
  const {
    id, primaryProject, digitalObjectType, descriptiveMetadata: initialDescriptiveMetadata,
    optimisticLockToken,
  } = digitalObject;
  const [descriptiveMetadata, setDescriptiveMetadata] = useState({});
  const [createDigitalObject, { error: createErrors }] = useMutation(createDigitalObjectMutation);
  const [updateDescriptiveMetadata, { data: updateData, error: updateErrors }] = useMutation(
    updateDescriptiveMetadataMutation,
    );

  // One day, maybe enable optionalChaining JS feature in babel to simplify lines like the one below.
  const userErrors = (updateData && updateData.updateDescriptiveMetadata && updateData.updateDescriptiveMetadata.userErrors) || [];
  
  const [identifiers, setIdentifiers] = useState(digitalObject.identifiers);

  const history = useHistory();


  const onChange = (fieldName, fieldVal) => {
    setDescriptiveMetadata(produce(descriptiveMetadata, (draft) => {
      draft[fieldName] = fieldVal;
    }));
  };

  const onIdentifierChange = (value) => {
    setIdentifiers(value);
  };

  const onSubmitHandler = () => {
    let historyPromise = () => {};
    const variables = {
      input: {
        id,
        descriptiveMetadata,
        identifiers,
        optimisticLockToken,
      },
    };
    let action;
    switch (formType) {
      case 'edit':
        action = updateDescriptiveMetadata;
        historyPromise = (res) => {
          const path = `/digital_objects/${res.data.updateDescriptiveMetadata.digitalObject.id}/metadata`;
          history.push(path);
          return { redirect: path };
        };
        break;
      case 'new':
        variables.input.project = { stringKey: primaryProject.stringKey };
        variables.input.digitalObjectType = digitalObjectType;
        action = createDigitalObject;
        historyPromise = (res) => {
          const path = `/digital_objects/${res.data.createDigitalObject.digitalObject.id}/metadata`;
          history.push(path);
          return { redirect: path };
        };
        break;
      default:
        action = () => {
          console.log(`Unhandled formType: ${formType}`);
          throw new Error(`Unhandled formType: ${formType}`);
        };
    }
    return action({ variables }).then(historyPromise);
  };

  const emptyDescriptiveMetadata = (dynamicFields, newObject) => {
    dynamicFields.forEach((i) => {
      switch (i.type) {
        case 'DynamicFieldGroup':
          newObject[i.stringKey] = [emptyDescriptiveMetadata(i.children, {})];
          break;
        case 'DynamicField':
          newObject[i.stringKey] = defaultFieldValue[i.fieldType];
          break;
        default:
          break;
      }
    });

    return newObject;
  };

  const keepEnabledFields = (enabledFieldIds, children) => children.map((c) => {
    switch (c.type) {
      case 'DynamicFieldGroup':
        c.children = keepEnabledFields(enabledFieldIds, c.children);
        return c.children.length > 0 ? c : null;
      case 'DynamicField':
        if (enabledFieldIds.includes(c.id)) return c;
        // if the ids are fetched in queries mixing ID scalars and JSON, strings must be compared
        if (enabledFieldIds.includes(String(c.id))) return c;
        return null;
      default:
        return c;
    }
  }).filter(c => c !== null);

  const variables = { project: { stringKey: primaryProject.stringKey }, digitalObjectType: digitalObjectType };
  const {
    loading: enabledFieldsLoading,
    error: enabledFieldsError,
    data: enabledFieldsData,
  } = useQuery(getEnabledDynamicFieldsQuery, { variables });

  const {
    loading: fieldGraphLoading,
    error: fieldGraphError,
    data: fieldGraphData,
  } = useQuery(getDynamicFieldGraphQuery, { variables: { } });

  if (enabledFieldsLoading || fieldGraphLoading) return (<></>);

  const anyErrors = (enabledFieldsError || fieldGraphError || createErrors || updateErrors);
  if (anyErrors) {
    return (<GraphQLErrors errors={anyErrors} />);
  }

  const enabledFieldIds = [];
  enabledFieldsData.enabledDynamicFields.forEach((enabledField) => {
    const { dynamicField, ...rest } = enabledField;
    if (rest.enabled) enabledFieldIds.push(dynamicField.id);
  });

  const filteredCategories = fieldGraphData.dynamicFieldGraph.dynamicFieldCategories.map((cat) => {
    cat.children = keepEnabledFields(enabledFieldIds, cat.children);
    return cat;
  }).filter(cat => cat.children.length > 0);

  const emptyData = {};
  filteredCategories.forEach((category) => {
    emptyDescriptiveMetadata(category.children, emptyData);
  });

  /*
    Merge emptyData and descriptiveMetadata so that we don't supply undefined values to the form
    as we build out the hierarchy.
   */
  merge(descriptiveMetadata, emptyData, initialDescriptiveMetadata);
  const cancelPath = (formType === 'new') ? '/digital_objects' : `/digital_objects/${id}/metadata`;
  return (
    <>
      <form>
        <ErrorList errors={userErrors.map((userError) => (`${userError.message} (path=${userError.path.join('/')})`))} />
        {
          filteredCategories.map(category => (
            <DynamicFieldCategory
              key={category.id}
              category={category}
              onChange={onChange}
              descriptiveMetadata={descriptiveMetadata}
              defaultFieldData={emptyData}
            />
          ))
        }

        <h4 className="text-orange">Identifiers</h4>
        <InputGroup>
          <TextInputWithAddAndRemove
            sm={12}
            values={identifiers}
            onChange={v => onIdentifierChange(v)}
          />
        </InputGroup>

        <FormButtons
          formType={formType}
          cancelTo={cancelPath}
          onSave={onSubmitHandler}
        />
      </form>
    </>
  );
}

export default MetadataForm;

MetadataForm.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
};
