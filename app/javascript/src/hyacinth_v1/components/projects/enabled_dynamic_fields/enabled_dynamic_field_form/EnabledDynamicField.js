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
  const { enabledFieldData } = field;

  const dispatchUpdate = (newEnabledFieldData) => {
    edfDispatch({ type: 'update', payload: { newEnabledFieldData } });
  };

  const onChange = (event) => {
    const {
      target: {
        type, name, value, checked,
      },
    } = event;

    // enabledFieldDataCallback(field.id, newData);
    dispatchUpdate(produce(enabledFieldData, (draft) => {
      const val = type === 'checkbox' ? checked : value;
      draft[name] = val;
    }));
  };

  const onFieldSetChange = (value, actionType) => {
    const detector = (f) => f.id !== actionType.removedValue.id;
    switch (actionType.action) {
      case 'select-option':
        // enabledFieldDataCallback(field.id, enabledFieldData);
        dispatchUpdate(produce(enabledFieldData, (draft) => {
          draft.fieldSets = value;
        }));
        break;
      case 'remove-value':
        // enabledFieldDataCallback(field.id, enabledFieldData);
        dispatchUpdate(produce(enabledFieldData, (draft) => {
          draft.fieldSets.splice(enabledFieldData.fieldSets.findIndex(detector), 1);
        }));
        break;
      default:
        break;
    }
  };

  const onEnable = (event) => {
    const { target: { checked } } = event;
    if (enabledFieldData.enabled !== checked) {
      // enabledFieldDataCallback(field.id, enabledFieldData);
      dispatchUpdate(produce(enabledFieldData, (draft) => {
        draft.enabled = checked;
      }));
    }
  };

  return (
    <Card
      key={`field_content_${field.id}`}
      className="mb-2"
      style={{ backgroundColor: '#eaeaea', border: userErrorPaths.includes(field.path) ? '1px solid #ff0000' : 'none' }}
    >
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
                  getOptionLabel={(option) => option.displayLabel}
                  getOptionValue={(option) => option.id}
                  styles={{
                    container: (styles) => ({ ...styles, fontSize: '.875rem', paddingTop: '.35rem' }),
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

EnabledDynamicField.propTypes = {
  field: PropTypes.shape({
    displayLabel: PropTypes.string,
    id: PropTypes.number,
    path: PropTypes.string,
    enabledFieldData: PropTypes.shape({
      defaultValue: PropTypes.string,
      enabled: PropTypes.bool,
      fieldSets: PropTypes.arrayOf(Object), // TODO: make this more specific
      required: PropTypes.bool,
      shareable: PropTypes.bool,
    }).isRequired,
  }).isRequired,
  edfDispatch: PropTypes.func.isRequired,
  readOnly: PropTypes.bool.isRequired,
  userErrorPaths: PropTypes.arrayOf(PropTypes.string).isRequired,
};

export default EnabledDynamicField;
