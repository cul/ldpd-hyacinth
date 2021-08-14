import React, { useState } from 'react';
import { useMutation, useQuery } from '@apollo/react-hooks';
import PropTypes from 'prop-types';
import {
  Row, Col, Form, Badge, Card,
} from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import Select from 'react-select';
import GraphQLErrors from '../../shared/GraphQLErrors';
import FormButtons from '../../shared/forms/FormButtons';
import { getEnabledDynamicFieldsQuery, updateEnabledDynamicFieldsMutation } from '../../../graphql/projects/enabledDynamicFields';
import { getDynamicFieldGraphQuery } from '../../../graphql/dynamicFieldCategories';

const DynamicField = ({ field, enabledFieldDataCallback, readOnly }) => {
  const [fieldSets] = useState([]);
  const [enabledFieldData, setEnabledFieldData] = useState(enabledFieldDataCallback(field.id));

  const onChange = (event) => {
    const {
      target: {
        type, name, value, checked,
      },
    } = event;

    const val = type === 'checkbox' ? checked : value;
    const newData = { ...enabledFieldData };
    newData[name] = val;
    enabledFieldDataCallback(field.id, newData);
    setEnabledFieldData(newData);
  };

  const onFieldSetChange = (value, actionType) => {
    const detector = f => f.id !== actionType.removedValue.id;
    switch (actionType.action) {
      case 'select-option':
        enabledFieldData.fieldSets = value;
        enabledFieldDataCallback(field.id, enabledFieldData);
        setEnabledFieldData({ ...enabledFieldData });
        break;
      case 'remove-value':
        enabledFieldData.fieldSets.splice(enabledFieldData.fieldSets.findIndex(detector), 1);
        enabledFieldDataCallback(field.id, enabledFieldData);
        setEnabledFieldData({ ...enabledFieldData });
        break;
      default:
        break;
    }
  };

  const onEnable = (event) => {
    const { target: { checked } } = event;
    if (enabledFieldData.enabled !== checked) {
      enabledFieldData.enabled = checked;
      setEnabledFieldData({ ...enabledFieldData });
      enabledFieldDataCallback(field.id, enabledFieldData);
    }
  };

  return (
    <Card key={`field_content_${field.id}`} className="mb-2" style={{ backgroundColor: '#eaeaea', border: 'none' }}>
      <Card.Body style={{ padding: '.75rem' }}>
        <Row>
          <Col md={2}>
            <Badge bg="info">{field.displayLabel}</Badge>
          </Col>
          <Col xs={4} md={2}>
            <Form.Check
              id={`enabled_${field.id}`}
              type="checkbox"
              checked={enabledFieldData.enabled}
              label="Enabled"
              name="enabled"
              onChange={onEnable}
              className="align-middle"
              inline
              disabled={readOnly}
            />
          </Col>
          <Col xs={4} md={2}>
            {
              enabledFieldData.enabled && (
                <Form.Check
                  id={`shareable_${field.id}`}
                  type="checkbox"
                  checked={enabledFieldData.shareable}
                  label="Shareable by Other Projects"
                  name="shareable"
                  className="align-middle"
                  onChange={onChange}
                  inline
                  disabled={readOnly}
                />
              )
            }
          </Col>
          <Col xs={4} md={2}>
            {
              enabledFieldData.enabled && (
                <Form.Check
                  id={`required_${field.id}`}
                  type="checkbox"
                  checked={enabledFieldData.required}
                  label="Required"
                  name="required"
                  className="align-middle"
                  onChange={onChange}
                  inline
                  disabled={readOnly}
                />
              )
            }
          </Col>
          <Col md={4}>
            {
              enabledFieldData.enabled && (
                <Form.Control
                  size="sm"
                  type="text"
                  name="defaultValue"
                  placeholder="Default value (optional)"
                  value={enabledFieldData.defaultValue || ''}
                  onChange={onChange}
                  disabled={readOnly}
                />
              )
            }
          </Col>
        </Row>
        {
          enabledFieldData.enabled && fieldSets.length > 0 && (
            <Row>
              <Form.Label column md={{ span: 2, offset: 2 }} disabled={readOnly}>
                <span className="float-start">Field Sets</span>
              </Form.Label>
              <Col md={8}>
                <Select
                  placeholder="No Field Sets Selected"
                  value={enabledFieldData.fieldSets}
                  name="fieldSets"
                  onChange={onFieldSetChange}
                  options={fieldSets}
                  isMulti
                  isSearchable={false}
                  isClearable={false}
                  isDisabled={readOnly}
                  getOptionLabel={option => option.displayLabel}
                  getOptionValue={option => option.id}
                  styles={{
                    container: styles => ({ ...styles, fontSize: '.875rem', paddingTop: '.35rem' }),
                  }}
                />
              </Col>
            </Row>
          )
        }
      </Card.Body>
    </Card>
  );
};

const DynamicFieldGroup = ({ group, enabledFieldDataCallback, readOnly }) => (
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
                      enabledFieldDataCallback={enabledFieldDataCallback}
                      readOnly={readOnly}
                    />
                  );
                case 'DynamicField':
                  return (
                    <DynamicField
                      field={child}
                      key={child.id}
                      enabledFieldDataCallback={enabledFieldDataCallback}
                      readOnly={readOnly}
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

const DynamicFieldCategory = ({ category, enabledFieldDataCallback, readOnly }) => (
  <>
    <h4 className="text-center text-orange">{category.displayLabel}</h4>
    { category.children.map(child => (
      <DynamicFieldGroup
        group={child}
        key={child.id}
        enabledFieldDataCallback={enabledFieldDataCallback}
        readOnly={readOnly}
      />
    )) }
  </>
);


export const EnabledDynamicFieldForm = ({ readOnly, projectStringKey, digitalObjectType }) => {
  const history = useHistory();
  const [enabledDynamicFields] = useState({});

  const variables = {
    project: { stringKey: projectStringKey }, digitalObjectType: digitalObjectType.toUpperCase(),
  };

  const {
    loading: enabledFieldsLoading,
    error: enabledFieldsError,
    data: enabledFieldsData,
  } = useQuery(getEnabledDynamicFieldsQuery, { variables });

  const {
    loading: fieldGraphLoading,
    error: fieldGraphError,
    data: fieldGraphData,
  } = useQuery(getDynamicFieldGraphQuery, { variables: { metadataForm: 'DESCRIPTIVE' } });

  const [updateEnabledFields, { error: updateError }] = useMutation(updateEnabledDynamicFieldsMutation);

  if (enabledFieldsLoading || fieldGraphLoading) return (<></>);

  if (enabledFieldsError || fieldGraphError || updateError) {
    return (<GraphQLErrors errors={enabledFieldsError || fieldGraphError || updateError} />);
  }

  enabledFieldsData.enabledDynamicFields.forEach((enabledField) => {
    const { dynamicField, ...rest } = enabledField;

    enabledDynamicFields[dynamicField.id] = { ...rest };
  });

  const dynamicFieldGraphs = fieldGraphData.dynamicFieldGraph.dynamicFieldCategories;

  const onSubmitHandler = () => {
    const enabledDynamicFieldsArray = [];

    Object.entries(enabledDynamicFields).forEach((entry) => {
      const [key, {
        enabled, _destroy, fieldSets, ...rest
      }] = entry;

      delete rest.project;
      delete rest.digitalObjectType;
      delete rest.type;
      const fieldSetIds = fieldSets.map(f => ({ id: f.id }));
      const newValue = {
        ...rest, fieldSets: fieldSetIds, dynamicField: { id: key },
      };

      if (enabled) {
        enabledDynamicFieldsArray.push(newValue);
      }
    });

    const input = {
      project: { stringKey: projectStringKey },
      digitalObjectType: digitalObjectType.toUpperCase(),
      enabledDynamicFields: enabledDynamicFieldsArray,
    };
    return updateEnabledFields({ variables: { input } });
  };

  const onSuccessHandler = (result) => {
    history.push(`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}`);
  };

  const enabledFieldDataCallback = (dynamicFieldId, data) => {
    if (data) {
      enabledDynamicFields[dynamicFieldId] = { ...data };
    }
    return enabledDynamicFields[dynamicFieldId];
  };

  return (
    <Form>
      {
        dynamicFieldGraphs.map(category => (
          <DynamicFieldCategory
            key={category.id}
            category={category}
            enabledFieldDataCallback={enabledFieldDataCallback}
            readOnly={readOnly}
          />
        ))
      }
      {
        !readOnly && (
          <FormButtons
            formType="edit"
            cancelTo={`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}`}
            onSave={onSubmitHandler}
            onSuccess={onSuccessHandler}
          />
        )
      }
    </Form>
  );
};

EnabledDynamicFieldForm.defaultProps = {
  readOnly: false,
};

EnabledDynamicFieldForm.propTypes = {
  readOnly: PropTypes.bool,
  projectStringKey: PropTypes.string.isRequired,
  digitalObjectType: PropTypes.string.isRequired,
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
  enabledFieldDataCallback: PropTypes.func.isRequired,
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
  enabledFieldDataCallback: PropTypes.func.isRequired,
  readOnly: PropTypes.bool.isRequired,
};

DynamicField.propTypes = {
  field: PropTypes.shape({
    id: PropTypes.number,
  }).isRequired,
  enabledFieldDataCallback: PropTypes.func.isRequired,
  readOnly: PropTypes.bool.isRequired,
};

export default EnabledDynamicFieldForm;
