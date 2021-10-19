import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Form, Badge, Card, Col, Row,
} from 'react-bootstrap';
import produce from 'immer';
import Select from 'react-select';

const EnabledDynamicField = ({
  field, edfDispatch, readOnly, userErrorPaths,
}) => {
  const [fieldSets] = useState([]);
  const { enabledFieldData, fieldSetOptions } = field;
  const selectedFieldSetIds = enabledFieldData.fieldSets.map((fieldSet) => fieldSet.id);
  const selectedFieldSetOptions = fieldSetOptions.filter((fieldSet) => selectedFieldSetIds.includes(fieldSet.id));

  const dispatchUpdate = (newEnabledFieldData) => {
    edfDispatch({ type: 'update', payload: { newEnabledFieldData } });
  };

  const onChange = (event) => {
    const {
      target: {
        type, name, value, checked,
      },
    } = event;

    dispatchUpdate(produce(enabledFieldData, (draft) => {
      const val = type === 'checkbox' ? checked : value;
      draft[name] = val;
    }));
  };

  const onFieldSetChange = (newValues) => {
    dispatchUpdate(produce(enabledFieldData, (draft) => {
      draft.fieldSets = newValues;
    }));
  };

  const onEnable = (event) => {
    const { target: { checked } } = event;
    if (enabledFieldData.enabled !== checked) {
      dispatchUpdate(produce(enabledFieldData, (draft) => {
        draft.enabled = checked;
      }));
    }
  };

  return (
    <Card
      key={`field_content_${field.id}`}
      className="mb-2"
      style={{ border: userErrorPaths.includes(field.path) ? '1px solid #ff0000' : 'none' }}
    >
      <Card.Header className="p-0 bg-transparent">
        <Badge bg="info">{field.displayLabel}</Badge>
      </Card.Header>
      <Card.Body className="p-2" style={{ backgroundColor: '#eaeaea' }}>
        <Row>
          <Col>
            <Row>
              <Col md="auto">
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
              <Col md="auto">
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
              <Col md="auto">
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
            </Row>
          </Col>
        </Row>
        <Row>
          {
            enabledFieldData.enabled
            && (
              <Col md={6} className="mt-2">
                <Row>
                  <Form.Label column lg="auto" htmlFor={`fieldSets-${field.id}`}>
                    Default Value
                  </Form.Label>
                  <Col lg>
                    <Form.Control
                      type="text"
                      name="defaultValue"
                      placeholder={readOnly ? '- none -' : 'Default value (optional)'}
                      value={enabledFieldData.defaultValue || ''}
                      onChange={onChange}
                      disabled={readOnly}
                    />
                  </Col>
                </Row>
              </Col>
            )
          }
          {
            enabledFieldData.enabled && fieldSetOptions.length > 0
            && (
              <Col className="mt-2">
                <Row>
                  <Form.Label column sm="auto" htmlFor={`fieldSets-${field.id}`}>
                    Field Sets
                  </Form.Label>
                  <Col>
                    <Select
                      id={`fieldSets-${field.id}`}
                      placeholder={readOnly ? '- none -' : 'Select one or more field sets (optional)'}
                      name="fieldSets"
                      onChange={onFieldSetChange}
                      options={fieldSetOptions}
                      getOptionLabel={(option) => option.displayLabel}
                      getOptionValue={(option) => option.id}
                      value={selectedFieldSetOptions}
                      isMulti
                      isSearchable={false}
                      isClearable
                      closeMenuOnSelect={false}
                      isDisabled={readOnly}
                    />
                  </Col>
                </Row>
              </Col>
            )
          }
        </Row>
      </Card.Body>
    </Card>
  );
};

EnabledDynamicField.propTypes = {
  field: PropTypes.shape({
    displayLabel: PropTypes.string,
    id: PropTypes.number,
    path: PropTypes.string,
    enabledFieldData: PropTypes.shape({
      defaultValue: PropTypes.string,
      enabled: PropTypes.bool,
      fieldSets: PropTypes.arrayOf(PropTypes.shape({
        id: PropTypes.string,
      })),
      required: PropTypes.bool,
      shareable: PropTypes.bool,
    }).isRequired,
    fieldSetOptions: PropTypes.arrayOf(
      PropTypes.shape({
        id: PropTypes.string,
        displayLabel: PropTypes.string,
      }),
    ).isRequired,
  }).isRequired,
  edfDispatch: PropTypes.func.isRequired,
  readOnly: PropTypes.bool.isRequired,
  userErrorPaths: PropTypes.arrayOf(PropTypes.string).isRequired,
};

export default EnabledDynamicField;
