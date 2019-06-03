import React from 'react';
import { Col, Form, Button } from 'react-bootstrap';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';

class ProjectNew extends React.Component {
  state = {
    project: {
      stringKey: '',
      displayLabel: '',
      projectUrl: '',
    },
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { project } = this.state;

    hyacinthApi.post('/projects', project)
      .then((res) => {
        const { project: { stringKey } } = res.data;

        this.props.history.push(`/projects/${stringKey}/core_data/edit`);
      });
  }

  onChangeHandler = (event) => {
    const { target } = event;
    this.setState(produce((draft) => { draft.project[target.name] = target.value; }));
  }

  render() {
    const { project: { stringKey, displayLabel, projectUrl } } = this.state;

    return (
      <>
        <ContextualNavbar
          title="Create New Project"
          rightHandLinks={[{ link: '/projects', label: 'Cancel' }]}
        />

        <Form onSubmit={this.onSubmitHandler}>
          <Form.Row>
            <Form.Group as={Col} sm={6}>
              <Form.Label>String Key</Form.Label>
              <Form.Control
                type="text"
                name="stringKey"
                value={stringKey}
                onChange={this.onChangeHandler}
              />
            </Form.Group>

            <Form.Group as={Col} sm={6}>
              <Form.Label>Display Label</Form.Label>
              <Form.Control
                type="text"
                name="displayLabel"
                value={displayLabel}
                onChange={this.onChangeHandler}
              />
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>Project URL</Form.Label>
              <Form.Control
                type="text"
                name="projectUrl"
                value={projectUrl}
                onChange={this.onChangeHandler}
              />
            </Form.Group>
          </Form.Row>

          <Button variant="primary" type="submit" onClick={this.onSubmitHandler}>Create</Button>
        </Form>
      </>
    );
  }
}

export default withErrorHandler(ProjectNew, hyacinthApi);
