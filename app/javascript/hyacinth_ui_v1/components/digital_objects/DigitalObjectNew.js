import React from 'react';
import produce from 'immer';
import { Col, Form, Collapse } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';

import ContextualNavbar from '../layout/ContextualNavbar';
import SubmitButton from '../layout/forms/SubmitButton';
import SelectInput from '../ui/forms/inputs/SelectInput';
import Label from '../ui/forms/Label';
import InputGroup from '../ui/forms/InputGroup';

import hyacinthApi, { projects } from '../../util/hyacinth_api';
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
        primaryProject: {
          stringKey: '',
        },
        digitalObjectType: '',
      },
    },
  }

  componentDidMount() {
    // Get all primary projects
    projects.search('project[is_primary]=true')
      .then((res) => {
        this.setState(produce((draft) => {
          draft.projectOptions = res.data.projects.filter(({ stringKey }) => (
            ability.can('create_objects', { subjectType: 'Project', stringKey })
          )).map(p => ({ value: p.stringKey, label: p.displayLabel }));
        }));
      })
      .catch(e => console.log(e));
  }

  onProjectChangeHandler = (value) => {
    this.setState(produce((draft) => {
      draft.digitalObject.digitalObjectDataJson.primaryProject.stringKey = value;
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
        digitalObjectDataJson: { digitalObjectType, primaryProject },
      },
    } = this.state;

    const { history: { push } } = this.props;

    push(`/digital_objects/new?primaryProject=${primaryProject.stringKey}&digitalObjectType=${digitalObjectType}`);
  }

  render() {
    const {
      projectOptions,
      digitalObjectTypeOptions,
      digitalObject: {
        digitalObjectDataJson: { digitalObjectType, primaryProject },
      },
    } = this.state;
    return (
      <>
        <ContextualNavbar
          title="Create Digital Object"
          rightHandLinks={[{ link: '/digital_objects', label: 'Back to Digital Objects' }]}
        />

        <Form className="m-3">
          <InputGroup>
            <Label sm={3}>Primary Project</Label>
            <SelectInput
              sm={9}
              name="primary_project"
              value={primaryProject.stringKey}
              onChange={v => this.onProjectChangeHandler(v)}
              options={projectOptions}
            />
          </InputGroup>

          <Collapse in={primaryProject.stringKey !== ''}>
            <div>
              <InputGroup>
                <Label sm={3}>Digital Object Type</Label>
                <SelectInput
                  sm={9}
                  inputName="digitalObjectType"
                  value={digitalObjectType}
                  onChange={v => this.onDigitalObjectTypeChangeHandler('digitalObjectType', v)}
                  options={digitalObjectTypeOptions}
                />
              </InputGroup>

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
