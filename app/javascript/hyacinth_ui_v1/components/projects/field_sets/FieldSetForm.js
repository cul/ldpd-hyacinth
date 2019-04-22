import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from "immer";

import CancelButton from 'hyacinth_ui_v1/components/layout/CancelButton';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

class FieldSetForm extends React.Component {
  state = {
    fieldSet: {
      displayLabel: ""
    }
  }

  componentDidMount() {
    if (this.props.match.params.id) {
      hyacinthApi.get(this.props.match.url.replace('edit', ''))
        .then(res => {
          this.setState(produce(draft => {
            draft.fieldSet.displayLabel = res.data.field_set.display_label
          }))
        })
        .catch(error => {
          console.log(error)
      });
    }
  }

  onSubmitHandler = (event) => {
    event.preventDefault()

    let data = {
      field_set: {
        display_label: this.state.fieldSet.displayLabel,
      }
    }

    this.props.submitFormAction(data)
  }

  onDeleteHandler = (event) => {
    event.preventDefault()

    hyacinthApi.delete(this.props.match.url.replace('edit', ''))
      .then(res => {
        this.props.history.push('/projects/' + this.props.match.params.string_key + '/field_sets');
      })
      .catch(error => {
        console.log(error)
    });
  }

  onChangeHandler = (event) => {
    let target = event.target
    this.setState(produce(draft => { draft.fieldSet[target.name] = target.value }))
  }

  render() {
    let deleteButton = "";

    if (this.props.match.params.id) {
      deleteButton = <Button variant="outline-danger" type="button" onClick={this.onDeleteHandler}>Delete</Button>
    }

    return (
      <div>
        <Form onSubmit={this.onSubmitHandler}>
          <Form.Group as={Row}>
            <Form.Label column sm={2}>Display Label</Form.Label>
            <Col sm={10}>
              <Form.Control
                type="text"
                name="displayLabel"
                value={this.state.fieldSet.displayLabel}
                onChange={this.onChangeHandler} />
            </Col>
          </Form.Group>

          <Form.Row>
            <Col sm={'auto'} className="mr-auto">{deleteButton}</Col>

            <Col sm={'auto'}>
              <CancelButton to={'/projects/' + this.props.match.params.string_key + '/field_sets'} />
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

export default withRouter(FieldSetForm)
