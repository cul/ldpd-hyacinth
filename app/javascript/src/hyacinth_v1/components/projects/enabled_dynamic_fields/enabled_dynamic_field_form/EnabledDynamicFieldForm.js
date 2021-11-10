import { useMutation, useQuery } from '@apollo/react-hooks';
import pick from 'lodash/pick';
import PropTypes from 'prop-types';
import React, { useReducer, useState } from 'react';
import { Card, Form } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { getDynamicFieldGraphQuery } from '../../../../graphql/dynamicFieldCategories';
import { getProjectFieldSetsQuery } from '../../../../graphql/projects';
import { getEnabledDynamicFieldsQuery, updateEnabledDynamicFieldsMutation } from '../../../../graphql/projects/enabledDynamicFields';
import ErrorList from '../../../shared/ErrorList';
import FormButtons from '../../../shared/forms/FormButtons';
import GraphQLErrors from '../../../shared/GraphQLErrors';
import { edfReducer, findDynamicFields } from './enabledDyanmicFieldFormHelpers';
import EnabledDynamicField from './EnabledDynamicField';

const edfDefaultState = { enabledFieldHierarchy: [] };

const DynamicFieldGroup = ({
  group, edfDispatch, readOnly, userErrorPaths,
}) => (
  <Card key={`group_content_${group.id}`} className="mt-2 mb-3">
    <Card.Body>
      <Card.Title>
        {group.displayLabel}
      </Card.Title>
      {
        group.children.length > 0 && (
          group.children.map((child) => {
            switch (child.type) {
              case 'DynamicFieldGroup':
                return (
                  <DynamicFieldGroup
                    group={child}
                    key={child.id}
                    edfDispatch={edfDispatch}
                    readOnly={readOnly}
                    userErrorPaths={userErrorPaths}
                  />
                );
              case 'DynamicField':
                return (
                  <EnabledDynamicField
                    field={child}
                    key={child.id}
                    edfDispatch={edfDispatch}
                    readOnly={readOnly}
                    userErrorPaths={userErrorPaths}
                  />
                );
              default:
                return null;
            }
          })
        )
      }
    </Card.Body>
  </Card>
);

const DynamicFieldCategory = ({
  category, edfDispatch, readOnly, userErrorPaths,
}) => (
  <>
    <h4 className="text-orange">{category.displayLabel}</h4>
    {category.children.map((child) => (
      <DynamicFieldGroup
        group={child}
        key={child.id}
        edfDispatch={edfDispatch}
        userErrorPaths={userErrorPaths}
        readOnly={readOnly}
      />
    ))}
  </>
);

const EnabledDynamicFieldForm = ({ readOnly, projectStringKey, digitalObjectType }) => {
  const [edfState, edfDispatch] = useReducer(edfReducer, edfDefaultState);
  const [initialStateLoaded, setInitialStateLoaded] = useState(false);
  const history = useHistory();

  const {
    loading: fieldGraphLoading, error: fieldGraphError, data: fieldGraphData,
  } = useQuery(getDynamicFieldGraphQuery, { variables: { metadataForm: 'DESCRIPTIVE' } });

  const {
    loading: enabledFieldsLoading, error: enabledFieldsError, data: enabledFieldsData,
  } = useQuery(getEnabledDynamicFieldsQuery, {
    variables: {
      project: { stringKey: projectStringKey }, digitalObjectType: digitalObjectType.toUpperCase(),
    },
  });

  const {
    loading: fieldSetsLoading, error: fieldSetsError, data: fieldSetsData,
  } = useQuery(getProjectFieldSetsQuery, { variables: { stringKey: projectStringKey } });

  const [updateEnabledFields, { data: updateData, error: updateError }] = useMutation(updateEnabledDynamicFieldsMutation);
  const userErrors = updateData?.updateProjectEnabledFields?.userErrors || [];

  if (fieldGraphLoading || enabledFieldsLoading || fieldSetsLoading) return <></>;
  if (!initialStateLoaded) {
    setInitialStateLoaded(true);
    edfDispatch({
      type: 'init',
      payload: {
        dynamicFieldGraph: fieldGraphData.dynamicFieldGraph,
        enabledDynamicFields: enabledFieldsData.enabledDynamicFields,
        fieldSetOptions: fieldSetsData.project.fieldSets,
      },
    });
    return <></>;
  }

  if (enabledFieldsError || fieldGraphError || fieldSetsError || updateError) {
    return <GraphQLErrors errors={enabledFieldsError || fieldGraphError || updateError} />;
  }

  const onSaveHandler = () => {
    const input = {
      project: { stringKey: projectStringKey },
      digitalObjectType: digitalObjectType.toUpperCase(),
      enabledDynamicFields: findDynamicFields(edfState.enabledFieldHierarchy).filter(
        (dynamicField) => dynamicField.enabledFieldData.enabled,
      ).map((dynamicField) => {
        const { enabledFieldData } = dynamicField;
        const enabledDynamicFieldInput = pick(enabledFieldData, [
          'required', 'locked', 'hidden', 'shareable', 'defaultValue',
        ]);
        enabledDynamicFieldInput.dynamicField = { id: enabledFieldData.dynamicField.id };
        enabledDynamicFieldInput.fieldSets = enabledFieldData.fieldSets.map((fieldSet) => ({ id: fieldSet.id }));
        return enabledDynamicFieldInput;
      }),
    };

    return (async () => {
      const res = await updateEnabledFields({ variables: { input } });
      if (res?.data?.updateProjectEnabledFields?.userErrors) {
        throw new Error('User errors encountered while updating enabled dynamic fields.');
      }
      return Promise.resolve(res);
    })();
  };

  const saveSuccessHandler = () => {
    history.push(`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}`);
  };

  const userErrorPaths = [];
  const userErrorMessages = [];
  if (userErrors) {
    userErrors.forEach((userError) => {
      const path = userError.path.join('/');
      const message = `${userError.message} (path=${path})`;
      userErrorPaths.push(path);
      userErrorMessages.push(message);
    });
  }

  return (
    <Form>
      {
        userErrors
        && (<ErrorList errors={userErrorMessages} />)
      }
      {
        edfState.enabledFieldHierarchy.dynamicFieldCategories.map((category) => (
          <DynamicFieldCategory
            key={category.id}
            category={category}
            edfDispatch={edfDispatch}
            userErrorPaths={userErrorPaths}
            readOnly={readOnly}
          />
        ))
      }
      {
        !readOnly && (
          <FormButtons
            formType="edit"
            cancelTo={`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}`}
            onSave={onSaveHandler}
            onSaveSuccess={saveSuccessHandler}
          />
        )
      }
    </Form>
  );
};

EnabledDynamicFieldForm.propTypes = {
  readOnly: PropTypes.bool,
  projectStringKey: PropTypes.string.isRequired,
  digitalObjectType: PropTypes.string.isRequired,
};
EnabledDynamicFieldForm.defaultProps = {
  readOnly: false,
};

DynamicFieldCategory.propTypes = {
  category: PropTypes.shape({
    id: PropTypes.number,
    displayLabel: PropTypes.string,
    children: PropTypes.arrayOf(
      PropTypes.shape({
        id: PropTypes.number,
      }),
    ),
  }).isRequired,
  edfDispatch: PropTypes.func.isRequired,
  userErrorPaths: PropTypes.arrayOf(PropTypes.string).isRequired,
  readOnly: PropTypes.bool.isRequired,
};

DynamicFieldGroup.propTypes = {
  group: PropTypes.shape({
    id: PropTypes.number.isRequired,
    displayLabel: PropTypes.string.isRequired,
    children: PropTypes.arrayOf(
      PropTypes.shape({
        id: PropTypes.number,
      }),
    ),
  }).isRequired,
  edfDispatch: PropTypes.func.isRequired,
  readOnly: PropTypes.bool.isRequired,
  userErrorPaths: PropTypes.arrayOf(PropTypes.string).isRequired,
};

export default EnabledDynamicFieldForm;
