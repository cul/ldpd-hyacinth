import React from 'react';
import produce from 'immer';
import axios from 'axios';
import {
  Row, Col, Form, Card,
} from 'react-bootstrap';

import hyacinthApi, {
  enabledDynamicFields, dynamicFieldCategories,
} from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import Label from './form/Label';

class ParentDigitalObjectForm extends React.PureComponent {
  state = {
    dynamicFields: []
  }

  componentDidMount = () => {
    const { projects, digitalObjectType } = this.props;

    // this.setState(produce((draft) => {
    //   draft.digitalObject.digitalObjectDataJson.projects[0].stringKey = project;
    //   draft.digitalObject.digitalObjectDataJson.digitalObjectType = digitalObjectType;
    // }));


    // Grab all the fields that are enabled for this digital object type within this project.
    // get enabled fields for this project/type combination
    // get all dynamic fields
    // remove any fields in the group of dynamic fields that arent enabled
    axios.all([
      enabledDynamicFields.all(projects[0].stringKey, digitalObjectType),
      dynamicFieldCategories.all(),
    ]).then(axios.spread((enabledFields, dynamicFieldGraph) => {
      const enabledFieldIds = enabledFields.data.enabledDynamicFields.map(f => f.dynamicFieldId);

      const dynamicFields = dynamicFieldGraph.data.dynamicFieldCategories.map((category) => {
        category.children = this.keepEnabledFields(enabledFieldIds, category.children);
        return category;
      }).filter(c => c.children.length > 0);

      this.setState(produce((draft) => {
        draft.dynamicFields = dynamicFields;
      }));
    }));
  }

  keepEnabledFields(enabledFieldIds, children) {
    return children.map((c) => {
      switch (c.type) {
        case 'DynamicFieldGroup':
          c.children = this.keepEnabledFields(enabledFieldIds, c.children);
          return c.children.length > 0 ? c : null;
        case 'DynamicField':
          return enabledFieldIds.includes(c.id) ? c : null;
        default:
          return c;
      }
    }).filter(c => c !== null);
  }

  renderCategory(category) {
    const { displayLabel, children } = category;
    return (
      <>
        <h5>{displayLabel}</h5>
        { children.map(c => this.renderGroup(c)) }
      </>
    );
  }

  renderGroup(group) {
    const { displayLabel, children } = group;

    return (
      <Card className="my-2">
        <Card.Header>{displayLabel}</Card.Header>
        <Card.Body>
          {
            children.map((c) => {
              switch (c.type) {
                case 'DynamicFieldGroup':
                  return this.renderGroup(c);
                case 'DynamicField':
                  return this.renderField(c);
                default:
                  return '';
              }
            })
          }
        </Card.Body>
      </Card>
    );
  }

  renderField(field) {
    const { displayLabel } = field;

    return (
      <Form.Group as={Row}>
        <Label sm={2}>{displayLabel}</Label>
        <Col sm={10}>
          <Form.Control
            size="sm"
            type="text"
            name=""
            value=""
            onChange=""
          />
        </Col>
      </Form.Group>
    )
  }

  render() {
    const { dynamicFields } = this.state;

    return (
      dynamicFields.map(category => this.renderCategory(category))
    );
  }
}

export default withErrorHandler(ParentDigitalObjectForm, hyacinthApi);
