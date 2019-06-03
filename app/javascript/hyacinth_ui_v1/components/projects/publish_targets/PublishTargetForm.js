import React from 'react';
import {
  Row, Col, Form
} from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import SubmitButton from '../../layout/forms/SubmitButton';
import DeleteButton from '../../layout/forms/DeleteButton';
import CancelButton from '../../layout/forms/CancelButton';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import hyacinthApi from '../../../util/hyacinth_api';

class PublishTargetForm extends React.Component {
  state = {
    formType: 'new',
    projectStringKey: '',
    publishTarget: {
      displayLabel: '',
      stringKey: '',
      publishUrl: '',
      apiKey: '',
    },
  }

  componentDidMount() {
    const { formType, projectStringKey, stringKey } = this.props;

    if (stringKey) {
      hyacinthApi.get(`/projects/${projectStringKey}/publish_targets/${stringKey}`)
        .then((res) => {
          const { publishTarget } = res.data;

          this.setState(produce((draft) => {
            draft.publishTarget = publishTarget;
          }));
        });
    }

    this.setState(produce((draft) => {
      draft.formType = formType;
      draft.projectStringKey = projectStringKey;
    }));
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { formType, projectStringKey, publishTarget, publishTarget: { stringKey } } = this.state;

    switch (formType) {
      case 'new':
        hyacinthApi.post(`/projects/${projectStringKey}/publish_targets`, publishTarget)
          .then((res) => {
            const { publishTarget: { stringKey } } = res.data;

            this.props.history.push(`/projects/${projectStringKey}/publish_targets/${stringKey}/edit`);
          });
        break;
      case 'edit':
        hyacinthApi.patch(`/projects/${projectStringKey}/publish_targets/${stringKey}`, publishTarget)
          .then(() => {
            this.props.history.push(`/projects/${projectStringKey}/publish_targets`);
          });
        break;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { match: { params: { projectStringKey, stringKey } }, history: { push } } = this.props;

    hyacinthApi.delete(`/projects/${projectStringKey}/publish_targets/${stringKey}`)
      .then(() => push(`/projects/${projectStringKey}/publish_targets`) );
  }

  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    this.setState(produce((draft) => { draft.publishTarget[name] = value; }));
  }

  render() {
    const {
      formType,
      projectStringKey,
      publishTarget: { stringKey, displayLabel, publishUrl, apiKey },
    } = this.state;

    return (
      <div>
        <Form onSubmit={this.onSubmitHandler}>
          <Form.Group as={Row}>
            <Form.Label column sm={2}>String Key</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="stringKey"
                value={stringKey}
                onChange={this.onChangeHandler}
                disabled={formType === 'edit'}
              />
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
            <Form.Label column sm={2}>Publish URL</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="publishUrl"
                value={publishUrl}
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
                value={apiKey}
                onChange={this.onChangeHandler}
              />
            </Col>
          </Form.Group>

          <Form.Row>
            <Col sm="auto" className="mr-auto">
              <DeleteButton formType={formType} onClick={this.onDeleteHandler} />
            </Col>

            <Col sm="auto">
              <CancelButton to={`/projects/${projectStringKey}/publish_targets`} />
            </Col>

            <Col sm="auto">
              <SubmitButton formType={formType} onClick={this.onSubmitHandler} />
            </Col>
          </Form.Row>
        </Form>
      </div>
    );
  }
}

export default withRouter(withErrorHandler(PublishTargetForm, hyacinthApi));
