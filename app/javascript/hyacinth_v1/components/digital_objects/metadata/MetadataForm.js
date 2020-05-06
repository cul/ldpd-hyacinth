import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import axios from 'axios';
import { merge } from 'lodash';
import { useHistory } from 'react-router-dom';

import hyacinthApi, {
  enabledDynamicFields, dynamicFieldCategories, digitalObject as digitalObjectApi
} from '../../../utils/hyacinthApi';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import TabHeading from '../../shared/tabs/TabHeading';
import FieldGroupArray from './FieldGroupArray';
import FormButtons from '../../shared/forms/FormButtons';
import InputGroup from '../../shared/forms/InputGroup';
import TextInputWithAddAndRemove from '../../shared/forms/inputs/TextInputWithAddAndRemove';

const defaultFieldValue = {
  string: '',
  textarea: '',
  integer: null,
  boolean: false,
  select: '',
  date: '',
  controlled_term: {},
};

function MetadataForm(props) {
  const { digitalObject, formType } = props;
  const { id, primaryProject, digitalObjectType, descriptiveMetadata: initialDescriptiveMetadata } = digitalObject;
  const [dynamicFieldHierarchy, setDynamicFieldHierarchy] = useState(null);
  const [defaultFieldData, setDefaultFieldData] = useState(null);
  const [descriptiveMetadata, setDescriptiveMetadata] = useState(null);
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
    if (formType === 'edit') {
      return digitalObjectApi.update(
        id,
        { digitalObject: { descriptiveMetadata, identifiers } },
      ).then(res => history.push(`/digital_objects/${res.data.digitalObject.uid}/metadata`));
    }

    if (formType === 'new') {
      return digitalObjectApi.create({
        digitalObject: { ...digitalObject, descriptiveMetadata, identifiers },
      }).then(res => history.push(`/digital_objects/${res.data.digitalObject.uid}/metadata`));
    }

    throw new Error(`Unhandled formType: ${formType}`);
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

  const keepEnabledFields = (enabledFieldIds, children) => {
    return children.map((c) => {
      switch (c.type) {
        case 'DynamicFieldGroup':
          c.children = keepEnabledFields(enabledFieldIds, c.children);
          return c.children.length > 0 ? c : null;
        case 'DynamicField':
          return enabledFieldIds.includes(c.id) ? c : null;
        default:
          return c;
      }
    }).filter(c => c !== null);
  };

  const renderCategory = (category) => {
    const { displayLabel, children } = category;
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
              onChange={v => onChange(fieldGroup.stringKey, v)}
            />
          ))
        }
      </div>
    );
  };

  // TODO: Replace effect below with GraphQL when we have a GraphQL DynamicFieldCategories API

  useEffect(() => {
    // Grab all dynamic fields. Grab all the fields that are enabled for this digital object
    // type within this project. Remove any fields in the group of dynamic fields that aren't
    // enabled for this object's projects.
    axios.all([
      enabledDynamicFields.all(primaryProject.stringKey, digitalObjectType),
      dynamicFieldCategories.all(),
    ]).then(axios.spread((enabledFields, dynamicFieldGraph) => {
      const enabledFieldIds = enabledFields.data.enabledDynamicFields.map(f => f.dynamicFieldId);

      const filteredDynamicFields = dynamicFieldGraph.data.dynamicFieldCategories.map((category) => {
        category.children = keepEnabledFields(enabledFieldIds, category.children);
        return category;
      }).filter(c => c.children.length > 0);

      const emptyData = {};
      filteredDynamicFields.forEach((category) => {
        emptyDescriptiveMetadata(category.children, emptyData);
      });

      setDynamicFieldHierarchy(filteredDynamicFields);
      setIdentifiers(identifiers);
      setDefaultFieldData(emptyData);

      // Merge emptyData and descriptiveMetadata so that we don't supply undefined values to the
      // form as we build out the hierarchy.
      setDescriptiveMetadata(merge({}, emptyData, initialDescriptiveMetadata));
    }));
  }, []);

  if (!(dynamicFieldHierarchy && descriptiveMetadata && defaultFieldData)) return (<></>);

  return (
    <>
      <form>
        { dynamicFieldHierarchy.map(category => renderCategory(category)) }

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
          cancelTo={`/digital_objects/${id}/metadata`}
          onSave={onSubmitHandler}
        />
      </form>
    </>
  );
}

export default withErrorHandler(MetadataForm, hyacinthApi);

MetadataForm.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
};
