import React from 'react';
import PropTypes from 'prop-types';
import {
  Row, Col, Form, Button, Card, Tabs, Tab,
} from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import { LinkContainer } from 'react-router-bootstrap';
import produce from 'immer';
import axios from 'axios';

import hyacinthApi from '../../util/hyacinth_api';
import DynamicFieldsAndGroupsTable from '../layout/dynamic_fields/DynamicFieldsAndGroupsTable';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import FormButtons from '../ui/forms/FormButtons';
import InputGroup from '../ui/forms/InputGroup';
import Label from '../ui/forms/Label';
import NumberInput from '../ui/forms/inputs/NumberInput';
import TextInput from '../ui/forms/inputs/TextInput';
import SelectInput from '../ui/forms/inputs/SelectInput';
import Checkbox from '../ui/forms/inputs/Checkbox';
import JSONInput from '../ui/forms/inputs/JSONInput';

class DynamicFieldGroupForm extends React.Component {
  state = {
    formType: '',
    fieldExportProfiles: [],
    dynamicFieldCategories: [],
    dynamicFieldGroup: {
      stringKey: '',
      displayLabel: '',
      sortOrder: '',
      isRepeatable: false,
      parentType: '',
      parentId: '',
      exportRules: [],
    },
    children: [],
  }

  componentDidMount() {
    const { id, formType, defaultValues } = this.props;

    if (formType === 'edit' && id) {
      axios.all([
        hyacinthApi.get(`/dynamic_field_groups/${id}`),
        hyacinthApi.get('/field_export_profiles')
      ]).then(axios.spread((group, profiles) => {
        const { data: { dynamicFieldGroup, dynamicFieldGroup: { parentType } } } = group;
        const { data: { fieldExportProfiles } } = profiles;

        if (parentType === 'DynamicFieldCategory') {
          this.loadCategories();
        }

        this.setState(produce((draft) => {
          draft.formType = formType;
          draft.dynamicFieldGroup = dynamicFieldGroup; // except children
          draft.children = dynamicFieldGroup.children;
          draft.fieldExportProfiles = fieldExportProfiles.map(p => ({ id: p.id, name: p.name }));
          draft.dynamicFieldGroup.exportRules = this.mergingExportProfiles(dynamicFieldGroup.exportRules, fieldExportProfiles)
        }));
      }));
    } else if (formType === 'new') {
      const { parentType, parentId } = defaultValues;

      if (parentType === 'DynamicFieldCategory') {
        this.loadCategories();
      }

      hyacinthApi.get('/field_export_profiles')
        .then((res) => {
          this.setState(produce((draft) => {
            draft.formType = formType;
            draft.dynamicFieldGroup.parentType = parentType || 'DynamicFieldCategory';
            draft.dynamicFieldGroup.parentId = parentId;
            draft.fieldExportProfiles = res.data.fieldExportProfiles.map(p => ({ id: p.id, name: p.name }));
            draft.dynamicFieldGroup.exportRules = this.mergingExportProfiles([], res.data.fieldExportProfiles)
          }));
        });
    }
  }

  onSave = () => {
    const { formType, dynamicFieldGroup: { id }, dynamicFieldGroup } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        return hyacinthApi.post('/dynamic_field_groups', { dynamicFieldGroup })
          .then((res) => {
            const { dynamicFieldGroup: { id: newId } } = res.data;

            push(`/dynamic_field_groups/${newId}/edit`);
          });
      case 'edit':
        return hyacinthApi.patch(`/dynamic_field_groups/${id}`, { dynamicFieldGroup })
      default:
        return null;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { id, history: { push } } = this.props;

    hyacinthApi.delete(`/dynamic_field_groups/${id}`)
      .then(() => push('/dynamic_fields'));
  }

  onChangeHandler(name, value) {
    this.setState(produce((draft) => {
      draft.dynamicFieldGroup[name] = value;
    }));
  }

  onExportRuleChange(index, value) {
    this.setState(produce((draft) => {
      draft.dynamicFieldGroup.exportRules[index].translationLogic = value;
    }));
  }

  mergingExportProfiles(exportRules, profiles) {
    let newExportRules = [...exportRules];

    profiles.forEach(p => {
      if (!exportRules.map(r => r.fieldExportProfileId).includes(p.id)) {
        newExportRules.push({ fieldExportProfileId: p.id, translationLogic: '{}'})
      }
    })

    return newExportRules;
  }

  loadCategories() {
    hyacinthApi.get('/dynamic_field_categories')
      .then((res) => {
        this.setState(produce((draft) => {
          draft.dynamicFieldCategories = res.data.dynamicFieldCategories.map(category => (
            { id: category.id, displayLabel: category.displayLabel }
          ));
        }));
      });
  }

  updateChildren = () => {
    const { dynamicFieldGroup: { id } } = this.state;

    hyacinthApi.get(`/dynamic_field_groups/${id}`)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.children = res.data.dynamicFieldGroup.children;
        }));
      });
  }

  render() {
    const {
      formType,
      dynamicFieldGroup: {
        id, stringKey, displayLabel, sortOrder, isRepeatable, parentType, parentId, exportRules,
      },
      dynamicFieldCategories,
      fieldExportProfiles,
      children,
    } = this.state;

    return (
      <Row>
        <Col sm={7}>
          <Form onSubmit={this.onSubmitHandler}>
            <InputGroup>
              <Label sm={12} xl={3}>String Key</Label>
              <TextInput
                sm={12}
                xl={9}
                value={stringKey}
                onChange={v => this.onChangeHandler('stringKey', v)}
                disabled={formType === 'edit'}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={12} xl={3}>Display Label</Label>
              <TextInput
                sm={12}
                xl={9}
                value={displayLabel}
                onChange={v => this.onChangeHandler('displayLabel', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={12} xl={3}>Sort Order</Label>
              <NumberInput
                sm={12}
                xl={9}
                value={sortOrder}
                onChange={v => this.onChangeHandler('sortOrder', v)}
              />
            </InputGroup>

            {
              parentType === 'DynamicFieldCategory' && (
                <InputGroup>
                  <Label sm={12} xl={3}>Dynamic Field Category</Label>
                  <SelectInput
                    sm={12}
                    xl={9}
                    value={parentId}
                    options={dynamicFieldCategories.map(c => ({ label: c.displayLabel, value: c.id }))}
                    onChange={v => this.onChangeHandler('parentId', v)}
                  />
                </InputGroup>
              )
            }

            <InputGroup>
              <Label sm={12} xl={3}>Is Repeatable?</Label>
              <Checkbox
                sm={12}
                xl={9}
                value={isRepeatable}
                onChange={v => this.onChangeHandler('isRepeatable', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={12} xl={3}>Export Rules</Label>
              <Col sm={12} xl={9}>
                {
                  exportRules.length > 0 ? (
                    <Tabs id="export_profiles">
                      {
                        exportRules.map((rule, index) => {
                          const { name } = fieldExportProfiles.find(p => p.id === rule.fieldExportProfileId);

                          return (
                            <Tab eventKey={name} title={name} key={name}>
                              <JSONInput
                                sm={12}
                                name={`${name}_input`}
                                value={rule.translationLogic}
                                onChange={v => this.onExportRuleChange(index, v)}
                              />
                            </Tab>
                          );
                        })
                      }
                    </Tabs>
                  ) : '-- None ---'
                }
              </Col>
            </InputGroup>

            <FormButtons
              formType={formType}
              cancelTo="/dynamic_fields"
              onDelete={this.onDeleteHandler}
              onSave={this.onSave}
            />
          </Form>
        </Col>
        <Col sm={5}>
          <Card>
            <Card.Header>Child Fields and Field Groups</Card.Header>
            <Card.Body>
              <DynamicFieldsAndGroupsTable rows={children} onChange={this.updateChildren}/>

              {
                formType === 'edit' && (
                  <>
                    <LinkContainer className="m-1" to={`/dynamic_fields/new?dynamicFieldGroupId=${id}`}>
                      <Button variant="secondary">New Child Field</Button>
                    </LinkContainer>

                    <LinkContainer className="m-1" to={`/dynamic_field_groups/new?parentId=${id}&parentType=DynamicFieldGroup`}>
                      <Button variant="secondary">New Child Field Group</Button>
                    </LinkContainer>
                  </>
                )
              }
            </Card.Body>
          </Card>
        </Col>
      </Row>
    );
  }
}

DynamicFieldGroupForm.defaultProps = {
  id: null,
};

DynamicFieldGroupForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  id: PropTypes.string,
};

export default withRouter(withErrorHandler(DynamicFieldGroupForm, hyacinthApi));
