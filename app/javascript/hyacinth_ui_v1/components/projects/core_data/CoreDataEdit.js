import React from 'react';
import {
  Row, Col, Form, Button,
} from 'react-bootstrap';
import producer from 'immer';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import CancelButton from '../../layout/forms/CancelButton';
import SubmitButton from '../../layout/forms/SubmitButton';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import { Can } from '../../../util/ability_context';

class CoreDataEdit extends React.Component {
  state = {
    project: {
      stringKey: '',
      displayLabel: '',
      projectUrl: '',
    },
  }

  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    this.setState(producer((draft) => { draft.project[name] = value; }));
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { project: { stringKey, displayLabel, projectUrl } } = this.state
    const data = { project: { displayLabel, projectUrl }, };

    hyacinthApi.patch(`/projects/${stringKey}`, data)
      .then((res) => {
        this.props.history.push(`/projects/${stringKey}/core_data`);
      });
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    hyacinthApi.delete(`/projects/${this.props.match.params.stringKey}`)
      .then((res) => {
        this.props.history.push('/projects/');
      });
  }

  componentDidMount = () => {
    hyacinthApi.get(`/projects/${this.props.match.params.stringKey}`)
      .then((res) => {
        const { project } = res.data;

        this.setState(producer((draft) => {
          draft.project = project;
        }));
      });
  }

  render() {
    const { project: { stringKey, displayLabel, projectUrl } } = this.state;
    return (
      <>
        <ProjectSubHeading>Editing Core Data</ProjectSubHeading>

        <Form as={Col} onSubmit={this.onSubmitHandler}>
          <Form.Group as={Row}>
            <Form.Label column sm={2}>String Key</Form.Label>
            <Col sm={10}>
              <Form.Control plaintext readOnly value={stringKey} />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Display Label</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="displayLabel"
                value={displayLabel}
                onChange={this.onChangeHandler}
              />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Project URL</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="projectUrl"
                value={projectUrl}
                onChange={this.onChangeHandler}
              />
            </Col>
          </Form.Group>

          <Form.Row>
            <Col sm="auto" className="mr-auto">
              <Can I="delete" a="Project">
                <Button variant="outline-danger" type="submit" onClick={this.onDeleteHandler}>Delete Project</Button>
              </Can>
            </Col>

            <Col sm="auto" className="ml-auto">
              <CancelButton to={`/projects/${stringKey}/core_data`} />
            </Col>

            <Col sm="auto">
              <SubmitButton formType="edit" onClick={this.onSubmitHandler} />
            </Col>
          </Form.Row>
        </Form>
      </>
    );
  }
}

export default withErrorHandler(CoreDataEdit, hyacinthApi);
