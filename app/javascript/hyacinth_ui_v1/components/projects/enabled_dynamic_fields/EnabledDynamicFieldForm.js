import React from 'react';
import {
  Row, Col, Form, Badge, Card,
} from 'react-bootstrap';
import produce from 'immer';
import { withRouter } from 'react-router-dom';
import axios from 'axios';
import Select from 'react-select';

import SubmitButton from '../../layout/forms/SubmitButton';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';

class EnabledDynamicFieldEdit extends React.Component {
  state = {
    disabled: true,
    enabledDynamicFields: {},
    dynamicFieldGraphs: [],
    fieldSets: [],
  }

  componentDidMount() {
    axios.all([this.getDynamicFieldGraph(), this.getEnabledDynamicFields()])
      .then(axios.spread((graph, enabledDynamicFields) => {
        const allFieldsHash = {};

        enabledDynamicFields.data.enabledDynamicFields.forEach((enabledField) => {
          const { dynamicFieldId, ...rest } = enabledField;

          allFieldsHash[dynamicFieldId] = { enabled: true, ...rest };
        });

        graph.data.dynamicFieldCategories.forEach((category) => {
          category.children.forEach(((group) => {
            this.getAllFields(group, allFieldsHash);
          }));
        });

        this.setState(produce((draft) => {
          draft.dynamicFieldGraphs = graph.data.dynamicFieldCategories;
          draft.enabledDynamicFields = allFieldsHash;
        }));
      }));

    const { projectStringKey, formType } = this.props;

    hyacinthApi.get(`/projects/${projectStringKey}/field_sets`)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.disabled = formType === 'show';
          draft.fieldSets = res.data.fieldSets;
        }));
      });
  }

  onChangeHandler(event, dynamicFieldId) {
    const {
      target: {
        type, name, value, checked,
      },
    } = event;

    const val = type === 'checkbox' ? checked : value;

    this.setState(produce((draft) => {
      draft.enabledDynamicFields[dynamicFieldId][name] = val;
    }));
  }

  onFieldSetChangeHandler(value, actionType, dynamicFieldId) {
    switch (actionType.action) {
      case 'select-option':
        this.setState(produce((draft) => {
          draft.enabledDynamicFields[dynamicFieldId].fieldSets = value;
        }));
        break;
      case 'remove-value':
        this.setState(produce((draft) => {
          const indexToRemove = draft.enabledDynamicFields[dynamicFieldId].fieldSets
            .findIndex(f => f.id !== actionType.removedValue.id);
          draft.enabledDynamicFields[dynamicFieldId].fieldSets.splice(indexToRemove, 1);
        }));
        break;
      default:
        break;
    }
  }

  onEnableHandler(event, dynamicFieldId) {
    const { target: { checked } } = event;

    if (checked) {
      this.setState(produce((draft) => {
        draft.enabledDynamicFields[dynamicFieldId].enabled = true;
        draft.enabledDynamicFields[dynamicFieldId]['_destroy'] = false;
      }));
    } else {
      this.setState(produce((draft) => {
        draft.enabledDynamicFields[dynamicFieldId].enabled = false;
        draft.enabledDynamicFields[dynamicFieldId]['_destroy'] = true;
      }));
    }
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { enabledDynamicFields } = this.state;
    const { projectStringKey, digitalObjectType } = this.props;

    const enabledDynamicFieldsArray = [];

    Object.entries(enabledDynamicFields).forEach((entry) => {
      const [key, {
        enabled, _destroy, fieldSets, ...rest
      }] = entry;

      const fieldSetIds = fieldSets.map(f => f.id);
      const newValue = {
        ...rest, _destroy, fieldSetIds, dynamicFieldId: key,
      };

      if (enabled || _destroy) {
        enabledDynamicFieldsArray.push(newValue);
      }
    });

    const path = `/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}`;
    hyacinthApi.patch(path, { enabledDynamicFields: enabledDynamicFieldsArray })
      .then(() => this.props.history.push(`${path}/edit`));
  }

  getAllFields(group, hash) {
    group.children.forEach((child) => {
      if (child.type === 'DynamicFieldGroup') {
        this.getAllFields(child, hash);
      } else if (child.type === 'DynamicField') {
        const { id } = child;
        if (!hash[id]) {
          hash[id] = {
            enabled: false, required: false, defaultValue: '', fieldSets: [],
          };
        }
      }
    });
  }

  getDynamicFieldGraph() {
    return hyacinthApi.get('/dynamic_field_categories');
  }

  getEnabledDynamicFields() {
    const { projectStringKey, digitalObjectType } = this.props;

    return hyacinthApi.get(`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}`);
  }

  renderGroup(group) {
    return (
      <Card key={`group_${group.id}`} className="mt-2 mb-3">
        <Card.Body>
          <Card.Title>
            {group.displayLabel}
          </Card.Title>
          {
            group.children.length > 0 && (
              group.children.map((child) => {
                switch (child.type) {
                  case 'DynamicFieldGroup':
                    return this.renderGroup(child);
                  case 'DynamicField':
                    return this.renderField(child);
                  default:
                    return null;
                }
              })
            )
          }
        </Card.Body>
      </Card>
    );
  }

  renderField(field) {
    const { enabledDynamicFields: { [field.id]: currentField }, fieldSets, disabled } = this.state;

    const onChange = event => this.onChangeHandler(event, field.id);

    return (
      <Card key={`field_${field.id}`} className="mb-2" style={{ backgroundColor: '#eaeaea', border: 'none' }}>
        <Card.Body style={{ padding: '.75rem' }}>
          <Row>
            <Col md={2}>
              <Badge variant="info">{field.displayLabel}</Badge>
            </Col>
            <Col xs={6} md={2}>
              <Form.Check
                id={`enabled_${field.id}`}
                type="checkbox"
                checked={currentField.enabled}
                label="Enabled"
                name="enabled"
                onChange={event => this.onEnableHandler(event, field.id)}
                className="align-middle"
                inline
                disabled={disabled}
              />
            </Col>
            <Col xs={6} md={2}>
              {
                currentField.enabled && (
                  <Form.Check
                    type="checkbox"
                    checked={currentField.required}
                    label="Required"
                    name="required"
                    className="align-middle"
                    onChange={onChange}
                    inline
                    disabled={disabled}
                  />
                )
              }
            </Col>
            <Col md={4}>
              {
                currentField.enabled && (
                  <Form.Control
                    size="sm"
                    type="text"
                    name="defaultValue"
                    placeholder="Default value (optional)"
                    value={currentField.defaultValue}
                    onChange={onChange}
                    disabled={disabled}
                  />
                )
              }
            </Col>
          </Row>
          {
            currentField.enabled && fieldSets.length > 0 && (
              <Row>
                <Form.Label column md={{ span: 2, offset: 2 }} disabled={disabled}>
                  <span className="float-left">Field Sets</span>
                </Form.Label>
                <Col md={8}>
                  <Select
                    placeholder="No Field Sets Selected"
                    value={currentField.fieldSets}
                    name="fieldSets"
                    onChange={
                      (value, action) => this.onFieldSetChangeHandler(value, action, field.id)
                    }
                    options={fieldSets}
                    isMulti
                    isSearchable={false}
                    isClearable={false}
                    isDisabled={disabled}
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
  }

  render() {
    const { dynamicFieldGraphs, disabled } = this.state;

    return (
      <Form onSubmit={this.onSubmitHandler}>
        {
          dynamicFieldGraphs.map(category => (
            <div key={`category_${category.id}`}>
              <h4 className="text-center text-orange">{category.displayLabel}</h4>
              { category.children.map(child => this.renderGroup(child)) }
            </div>
          ))
        }
        {
          !disabled && (
            <Row>
              <Col sm="auto" className="ml-auto">
                <SubmitButton onClick={this.onSubmitHandler} formType="edit" />
              </Col>
            </Row>
          )
        }
      </Form>
    );
  }
}

export default withRouter(withErrorHandler(EnabledDynamicFieldEdit, hyacinthApi));
