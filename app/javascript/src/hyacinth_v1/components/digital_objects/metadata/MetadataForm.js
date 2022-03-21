import React, { useState } from 'react';
import { useMutation, useQuery } from '@apollo/react-hooks';
import PropTypes from 'prop-types';
import produce from 'immer';
import { merge } from 'lodash';
import { useHistory } from 'react-router-dom';

import FieldGroup from './FieldGroup';
import FieldGroupArray from './FieldGroupArray';
import TitleForm from './TitleForm';
import FormButtons from '../../shared/forms/FormButtons';
import GraphQLErrors from '../../shared/GraphQLErrors';
import InputGroup from '../../shared/forms/InputGroup';
import TextInputWithAddAndRemove from '../../shared/forms/inputs/TextInputWithAddAndRemove';
import { createDigitalObjectMutation, updateDescriptiveMetadataMutation } from '../../../graphql/digitalObjects';
import { getEnabledDynamicFieldsQuery } from '../../../graphql/projects/enabledDynamicFields';
import { getDynamicFieldGraphQuery } from '../../../graphql/dynamicFieldCategories';
import { emptyDataForCategories, filterDynamicFieldCategories, padForEnabledFields } from '../../../utils/dynamicFieldStructures';
import UserErrorsList from '../../shared/UserErrorsList';

const DynamicFieldCategory = (props) => {
  const {
    category, onChange, descriptiveMetadata, defaultFieldData,
  } = props;
  const { displayLabel, children } = category;
  const changeHandler = (sk) => {
    const stringKey = sk;
    return (v) => onChange(stringKey, v);
  };
  return (
    <div key={displayLabel}>
      <h4 className="text-orange">{displayLabel}</h4>
      {
        children.map((fieldGroup) => (
          <FieldGroupArray
            key={`array_${fieldGroup.stringKey}`}
            component={FieldGroup}
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

DynamicFieldCategory.propTypes = {
  descriptiveMetadata: PropTypes.objectOf(PropTypes.any).isRequired,
  onChange: PropTypes.func.isRequired,
  category: PropTypes.shape(
    {
      displayLabel: PropTypes.string,
      children: PropTypes.arrayOf(PropTypes.any),
    },
  ).isRequired,
  defaultFieldData: PropTypes.objectOf(PropTypes.any).isRequired,
};

function MetadataForm(props) {
  const { digitalObject, formType } = props;
  const {
    id, primaryProject, digitalObjectType, descriptiveMetadata: initialDescriptiveMetadata,
    optimisticLockToken,
  } = digitalObject;
  const [descriptiveMetadata, setDescriptiveMetadata] = useState({});
  const [createDigitalObject, { data: createData, error: createErrors }] = useMutation(createDigitalObjectMutation);
  const [updateDescriptiveMetadata, { data: updateData, error: updateErrors }] = useMutation(
    updateDescriptiveMetadataMutation,
  );

  let userErrors = [];
  // One day, maybe enable optionalChaining JS feature in babel to simplify lines like the one below.
  if (createData && createData.createDigitalObject && createData.createDigitalObject.userErrors) {
    userErrors = createData.createDigitalObject.userErrors;
  } else if (updateData && updateData.updateDescriptiveMetadata && updateData.updateDescriptiveMetadata.userErrors) {
    userErrors = updateData.updateDescriptiveMetadata.userErrors;
  }

  const [identifiers, setIdentifiers] = useState(digitalObject.identifiers);
  const [title, setTitle] = useState(digitalObject.title);

  const history = useHistory();

  const onChange = (fieldName, fieldVal) => {
    setDescriptiveMetadata(produce(descriptiveMetadata, (draft) => {
      draft[fieldName] = fieldVal;
    }));
  };

  const onIdentifierChange = (value) => {
    setIdentifiers(value);
  };

  const onTitleChange = (value) => {
    setTitle(value);
  };

  const onSaveSuccess = (res) => {
    if (res.data.createDigitalObject && res.data.createDigitalObject.digitalObject) {
      const { digitalObject: { id: objId } } = res.data.createDigitalObject;
      if (objId) {
        const path = `/digital_objects/${objId}/metadata`;
        history.push(path);
      }
    } else if (res.data.updateDescriptiveMetadata && res.data.updateDescriptiveMetadata.digitalObject) {
      const { updateDescriptiveMetadata: { digitalObject: { id: objId } } } = res.data;
      if (objId) {
        const path = `/digital_objects/${objId}/metadata`;
        history.push(path);
      }
    }
  };

  const onSave = () => {
    const variables = {
      input: {
        id,
        title,
        descriptiveMetadata,
        identifiers,
        optimisticLockToken,
      },
    };
    let action;
    switch (formType) {
      case 'edit':
        action = updateDescriptiveMetadata;
        break;
      case 'new':
        variables.input.project = { stringKey: primaryProject.stringKey };
        variables.input.digitalObjectType = digitalObjectType.toUpperCase();
        action = createDigitalObject;
        break;
      default:
        action = () => {
          console.log(`Unhandled formType: ${formType}`);
          throw new Error(`Unhandled formType: ${formType}`);
        };
    }
    return action({ variables });
  };

  const {
    loading: enabledFieldsLoading,
    error: enabledFieldsError,
    data: enabledFieldsData,
  } = useQuery(
    getEnabledDynamicFieldsQuery,
    { variables: { project: { stringKey: primaryProject.stringKey }, digitalObjectType: digitalObjectType.toUpperCase() } },
  );

  const {
    loading: fieldGraphLoading,
    error: fieldGraphError,
    data: fieldGraphData,
  } = useQuery(getDynamicFieldGraphQuery, { variables: {} });

  if (enabledFieldsLoading || fieldGraphLoading) return (<></>);

  const anyErrors = (enabledFieldsError || fieldGraphError || createErrors || updateErrors);
  if (anyErrors) {
    return (<GraphQLErrors errors={anyErrors} />);
  }
  const { enabledDynamicFields } = enabledFieldsData;
  const { dynamicFieldGraph: { dynamicFieldCategories } } = fieldGraphData;
  const filteredCategories = filterDynamicFieldCategories(dynamicFieldCategories, enabledDynamicFields);

  const emptyData = emptyDataForCategories(filteredCategories);
  /*
    Merge emptyData and descriptiveMetadata so that we don't supply undefined values to the form
    as we build out the hierarchy.
   */
  merge(descriptiveMetadata, emptyData, initialDescriptiveMetadata);
  // Pad descriptiveMetadata out for all enabled fields so that form only encounters defined values
  padForEnabledFields(descriptiveMetadata, emptyData);

  const cancelPath = (formType === 'new') ? '/digital_objects' : `/digital_objects/${id}/metadata`;
  return (
    <>
      <form>
        <UserErrorsList userErrors={userErrors} />
        <TitleForm title={title} onChange={onTitleChange} />
        {
          filteredCategories.map((category) => (
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
            onChange={(v) => onIdentifierChange(v)}
          />
        </InputGroup>

        <FormButtons
          formType={formType}
          cancelTo={cancelPath}
          onSave={onSave}
          onSaveSuccess={onSaveSuccess}
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
