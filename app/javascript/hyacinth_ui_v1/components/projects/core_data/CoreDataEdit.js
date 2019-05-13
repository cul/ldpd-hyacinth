import React from 'react';
import {
  Row, Col, Form, Button,
} from 'react-bootstrap';
import producer from 'immer';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import CancelButton from '../../layout/CancelButton';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';

class CoreDataEdit extends React.Component {
  state = {
    project: {
      stringKey: '',
      displayLabel: '',
      projectUrl: '',
    },
  }

  onChangeHandler = (event) => {
    const { target } = event;
    this.setState(producer((draft) => { draft.project[target.name] = target.value; }));
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const data = {
      project: {
        display_label: this.state.project.displayLabel,
        project_url: this.state.project.projectUrl,
      },
    };

    hyacinthApi.patch(`/projects/${this.props.match.params.stringKey}`, data)
      .then((res) => {
        this.props.history.push(`/projects/${this.props.match.params.stringKey}/core_data`);
      });
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    hyacinthApi.delete(`/projects/${this.props.match.params.stringKey}`)
      .then((res) => {
        this.props.history.push('/projects/');
      })
      .catch((error) => {
        console.log(error);
      });
  }

  componentDidMount = () => {
    hyacinthApi.get(`/projects/${this.props.match.params.stringKey}`)
      .then((res) => {
        const { stringKey, displayLabel, projectUrl } = res.data.project;

        this.setState(producer((draft) => {
          draft.project.stringKey = stringKey;
          draft.project.displayLabel = displayLabel;
          draft.project.projectUrl = projectUrl;
        }));
      })
      .catch((error) => {
        console.log(error);
      });
  }

  render() {
    return (
      <>
        <ProjectSubHeading>Editing Core Data</ProjectSubHeading>

        <Form as={Col} onSubmit={this.onSubmitHandler}>
          <Form.Group as={Row}>
            <Form.Label column sm={2}>String Key</Form.Label>
            <Col sm={10}>
              <Form.Control plaintext readOnly value={this.state.project.stringKey} />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Display Label</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="displayLabel"
                value={this.state.project.displayLabel}
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
                value={this.state.project.projectUrl}
                onChange={this.onChangeHandler}
              />
            </Col>
          </Form.Group>

          <Form.Row>
            <Col sm="auto" className="mr-auto">
              <Button variant="outline-danger" type="submit" onClick={this.onDeleteHandler}>Delete Project</Button>
            </Col>

            <Col sm="auto" className="ml-auto">
              <CancelButton to={`/projects/${this.props.match.params.stringKey}/core_data`} />
            </Col>

            <Col sm="auto">
              <Button variant="primary" type="submit" onClick={this.onSubmitHandler}>Save</Button>
            </Col>
          </Form.Row>
        </Form>
      </>
    );
  }
}

export default withErrorHandler(CoreDataEdit, hyacinthApi);
