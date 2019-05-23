import React from 'react';
import {
  Row, Col, Form, Button,
} from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import CancelButton from 'hyacinth_ui_v1/components/layout/forms/CancelButton';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

class PublishTargetForm extends React.Component {
  state = {
    formType: '',
    publishTarget: {
      displayLabel: '',
      stringKey: '',
      publishUrl: '',
      apiKey: '',
    },
  }

  componentDidMount() {
    const { projectStringKey, stringKey } = this.props.match.params

    if (stringKey) {
      hyacinthApi.get(`/projects/${projectStringKey}/publish_targets/${stringKey}`)
        .then((res) => {
          const { publishTarget } = res.data

          this.setState(produce(draft => {
            draft.formType = 'edit';
            draft.publishTarget = publishTarget;
          }));
        })
        .catch((error) => {
          console.log(error);
        });
    } else {
      this.setState(produce((draft) => {
        draft.formType = 'new';
      }));
    }
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const data = {
      publishTarget: {
        displayLabel: this.state.publishTarget.displayLabel,
        publishUrl: this.state.publishTarget.publishUrl,
        apiKey: this.state.publishTarget.apiKey,
      },
    };

    if (this.state.formType == 'new') {
      data.publishTarget.stringKey = this.state.publishTarget.stringKey;
    }

    this.props.submitFormAction(data);
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { projectStringKey, stringKey } = this.props.match.params

    hyacinthApi.delete(`/projects/${projectStringKey}/publish_targets/${stringKey}`)
      .then((res) => {
        this.props.history.push(`/projects/${projectStringKey}/publish_targets`);
      });
  }

  onChangeHandler = (event) => {
    const { target } = event;
    this.setState(produce((draft) => { draft.publishTarget[target.name] = target.value; }));
  }

  render() {
    let deleteButton = '';

    if (this.state.formType == 'edit') {
      deleteButton = <Button variant="outline-danger" type="button" onClick={this.onDeleteHandler}>Delete</Button>;
    }

    let stringKey = '';
    if (this.state.formType == 'new') {
      stringKey = (
        <Form.Control
          type="text"
          name="stringKey"
          value={this.state.publishTarget.stringKey}
          onChange={this.onChangeHandler}
        />
      );
    } else {
      stringKey = <Form.Control plaintext readOnly value={this.state.publishTarget.stringKey} />;
    }

    return (
      <div>
        <Form onSubmit={this.onSubmitHandler}>
          <Form.Group as={Row}>
            <Form.Label column sm={2}>String Key</Form.Label>
            <Col sm={10}>
              {stringKey}
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Display Label</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="displayLabel"
                value={this.state.publishTarget.displayLabel}
                onChange={this.onChangeHandler}
              />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Publish URL</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="publishUrl"
                value={this.state.publishTarget.publishUrl}
                onChange={this.onChangeHandler}
              />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>API Key</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="apiKey"
                value={this.state.publishTarget.apiKey}
                onChange={this.onChangeHandler}
              />
            </Col>
          </Form.Group>

          <Form.Row>
            <Col sm="auto" className="mr-auto">{deleteButton}</Col>

            <Col sm="auto">
              <CancelButton to={`/projects/${this.props.match.params.stringKey}/publish_targets`} />
            </Col>

            <Col sm="auto">
              <Button variant="primary" type="submit" onClick={this.onSubmitHandler}>{this.props.submitButtonName}</Button>
            </Col>
          </Form.Row>
        </Form>
      </div>
    );
  }
}

export default withRouter(PublishTargetForm);
