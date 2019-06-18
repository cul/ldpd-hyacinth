import React from 'react';
import produce from 'immer';
import {
  Row, Col, Form, Button, Collapse,
} from 'react-bootstrap';
import { withRouter } from 'react-router-dom';


import ContextualNavbar from '../layout/ContextualNavbar';
import SubmitButton from '../layout/forms/SubmitButton';
import SelectInput from '../layout/forms/SelectInput';
import hyacinthApi from '../../util/hyacinth_api';
import ability from '../../util/ability';

const allParentDigitalObjectTypes = [
  'item', 'site',
]

class DigitalObjectNew extends React.Component {
  state = {
    projectOptions: [],
    digitalObjectTypeOptions: [
      { label: 'Item', value: 'item' },
      { label: 'Site', value: 'site' },
    ],
    digitalObject: {
      digitalObjectDataJson: {
        projects: [{
          stringKey: '',
        }],
        digitalObjectType: '',
      },
    },
  }

  componentDidMount() {
    // Get all projects that a user has 'create_objects' privileges for.
    hyacinthApi.get('/projects/')
      .then((res) => {
        this.setState(produce((draft) => {
          draft.projectOptions = res.data.projects.filter(({ stringKey }) => (
            ability.can('create_objects', { subjectType: 'Project', stringKey })
          )).map(p => ({ value: p.stringKey, label: p.displayLabel }));
        }));
      })
      .catch(e => console.log(e));
  }

  onProjectChangeHandler = (name, value) => {
    this.setState(produce((draft) => {
      draft.digitalObject.digitalObjectDataJson.projects[0].stringKey = value;
    }));

    // TODO
    // Reload all the potential types of digital object types.
    // Query for all three digital object types, filter out any types that do not have any enabled
    // fields within the project.
  }

  onDigitalObjectTypeChangeHandler = (name, value) => {
    this.setState(produce((draft) => {
      draft.digitalObject.digitalObjectDataJson.digitalObjectType = value;
    }));
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const {
      digitalObject: {
        digitalObjectDataJson: { digitalObjectType, projects },
      },
    } = this.state;

    const { history: { push } } = this.props;

    push(`/digital_objects/new?project=${projects[0].stringKey}&digitalObjectType=${digitalObjectType}`);
  }

  render() {
    const {
      projectOptions,
      digitalObjectTypeOptions,
      digitalObject: {
        digitalObjectDataJson: { digitalObjectType, projects },
      },
    } = this.state;
    return (
      <>
        <ContextualNavbar
          title="Create Digital Object"
          rightHandLinks={[{ link: '/digital_objects', label: 'Back to Digital Objects' }]}
        />

        <Form>
          <Form.Group as={Row} className="mb-1">
            <Form.Label column sm={3}>Project</Form.Label>
            <Col sm={9} style={{ alignSelf: 'center' }}>
              <SelectInput
                name="project"
                value={projects[0].stringKey}
                onChange={this.onProjectChangeHandler}
                options={projectOptions}
              />
            </Col>
          </Form.Group>

          <Collapse in={projects[0].stringKey !== ''}>
            <div>
              <Form.Group as={Row} className="mb-1">
                <Form.Label column sm={3}>Digital Object Type</Form.Label>
                <Col sm={9} style={{ alignSelf: 'center' }}>
                  <SelectInput
                    name="digitalObjectType"
                    value={digitalObjectType}
                    onChange={this.onDigitalObjectTypeChangeHandler}
                    options={digitalObjectTypeOptions}
                  />
                </Col>
              </Form.Group>

              <Collapse in={digitalObjectType !== ''}>
                <div>
                  <Form.Row>
                    <Col sm="auto" className="ml-auto">
                      <SubmitButton formType="new" onClick={this.onSubmitHandler} />
                    </Col>
                  </Form.Row>
                </div>
              </Collapse>
            </div>
          </Collapse>
        </Form>
      </>
    );
  }
}

export default withRouter(DigitalObjectNew);
