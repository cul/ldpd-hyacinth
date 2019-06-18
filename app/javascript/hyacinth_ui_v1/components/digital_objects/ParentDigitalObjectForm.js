import React from 'react';
import produce from 'immer';
import axios from 'axios';
import {
  Row, Col, Form, Card,
} from 'react-bootstrap';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi, {
  enabledDynamicFields, dynamicFieldCategories, digitalObject,
} from '../../util/hyacinth_api';
import SubmitButton from '../layout/forms/SubmitButton';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';

class ParentDigitalObjectForm extends React.PureComponent {
  state = {
    dynamicFields: [],
    digitalObject: {
      digitalObjectDataJson: {
        serializationVersion: '1',
        projects: [{
          stringKey: '',
        }],
        digitalObjectType: '',
        dynamicFieldData: {},
      },
    },
  }

  componentDidMount = () => {
    const { project, digitalObjectType } = this.props;

    this.setState(produce((draft) => {
      draft.digitalObject.digitalObjectDataJson.projects[0].stringKey = project;
      draft.digitalObject.digitalObjectDataJson.digitalObjectType = digitalObjectType;
    }));

    // Get Project Display Label

    // Grab all the fields that are enabled for this digital object type within this project.
    // get enabled fields for this project/type combination
    // get all dynamic fields
    // remove any fields in the group of dynamic fields that arent enabled
    axios.all([
      enabledDynamicFields.all(project, digitalObjectType),
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

      console.log(dynamicFields);
    }));
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { digitalObject: data } = this.state;
    // const { history: { push } } = this.props;

    digitalObject.create(data)
      .then(res => console.log(res.data)); //push(`/digital_objects/${res.data.id}/edit`)
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
        <Card.Header className="py-1 px-2">{displayLabel}</Card.Header>
        <Card.Body className="p-2">
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
        <Form.Label column sm={2}>{displayLabel}</Form.Label>
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
    const { project, digitalObjectType } = this.props;
    const { dynamicFields } = this.state;

    return (
      <>
        <ContextualNavbar
          title={`New ${digitalObjectType}`}
          rightHandLinks={[{ link: '/digital_objects', label: 'Back to Digital Objects' }]}
        />

        <p>Project: {project}</p>
        <p>UID/PID: - Assigned After Save -</p>
        <p>DOI: Unavailable</p>

        <Form>
          { dynamicFields.map(category => this.renderCategory(category)) }
          <Row>
            <Col sm="auto" className="ml-auto">
              <SubmitButton onClick={this.onSubmitHandler} formType="new" />
            </Col>
          </Row>
        </Form>

      </>
    );
  }
}

export default withErrorHandler(ParentDigitalObjectForm, hyacinthApi);
