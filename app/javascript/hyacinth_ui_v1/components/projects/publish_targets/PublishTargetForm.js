import React from 'react';
import { Row, Col, Form, Button } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import CancelButton from 'hyacinth_ui_v1/components/layout/CancelButton';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

class PublishTargetForm extends React.Component {
  state = {
    formType: '',
    publishTarget: {
      displayLabel: '',
      stringKey: '',
      publishUrl: '',
      apiKey: '',
    }
  }

  componentDidMount() {
    if (this.props.match.params.publish_target_string_key) {
      hyacinthApi.get(this.props.match.url.replace('edit', ''))
        .then(res => {
          this.setState(produce(draft => {
            draft.formType = 'edit'
            draft.publishTarget.displayLabel = res.data.publish_target.display_label
            draft.publishTarget.stringKey = res.data.publish_target.string_key
            draft.publishTarget.publishUrl = res.data.publish_target.publish_url
            draft.publishTarget.apiKey = res.data.publish_target.api_key
          }))
        })
        .catch(error => {
          console.log(error)
      });
    } else {
      this.setState(produce(draft => {
        draft.formType = 'new'
      }))
    }
  }

  onSubmitHandler = (event) => {
    event.preventDefault()

    let data = {
      publish_target: {
        display_label: this.state.publishTarget.displayLabel,
        publish_url: this.state.publishTarget.publishUrl,
        api_key: this.state.publishTarget.apiKey,
      }
    }

    if (this.state.formType == 'new') {
      data.publish_target.string_key = this.state.publishTarget.stringKey
    }

    this.props.submitFormAction(data)
  }

  onDeleteHandler = (event) => {
    event.preventDefault()

    hyacinthApi.delete(this.props.match.url.replace('edit', ''))
      .then(res => {
        this.props.history.push('/projects/' + this.props.match.params.string_key + '/publish_targets');
      });
  }

  onChangeHandler = (event) => {
    let target = event.target
    this.setState(produce(draft => { draft.publishTarget[target.name] = target.value }))
  }

  render() {
    let deleteButton = "";

    if (this.state.formType == 'edit') {
      deleteButton = <Button variant="outline-danger" type="button" onClick={this.onDeleteHandler}>Delete</Button>
    }

    let stringKey = ""
      if (this.state.formType == 'new') {
        stringKey = <Form.Control
                      type="text"
                      name="stringKey"
                      value={this.state.publishTarget.stringKey}
                      onChange={this.onChangeHandler} />
      } else {
        stringKey = <Form.Control plaintext readOnly value={this.state.publishTarget.stringKey} />
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
                onChange={this.onChangeHandler} />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Publish URL</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="publishUrl"
                value={this.state.publishTarget.publishUrl}
                onChange={this.onChangeHandler} />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>API Key</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="apiKey"
                value={this.state.publishTarget.apiKey}
                onChange={this.onChangeHandler} />
            </Col>
          </Form.Group>

          <Form.Row>
            <Col sm={'auto'} className="mr-auto">{deleteButton}</Col>

            <Col sm={'auto'}>
              <CancelButton to={'/projects/' + this.props.match.params.string_key + '/publish_targets'} />
            </Col>

            <Col sm={'auto'}>
              <Button variant="primary" type="submit" onClick={this.onSubmitHandler}>{this.props.submitButtonName}</Button>
            </Col>
          </Form.Row>
        </Form>
      </div>
    )
  }
}

export default withRouter(PublishTargetForm)
