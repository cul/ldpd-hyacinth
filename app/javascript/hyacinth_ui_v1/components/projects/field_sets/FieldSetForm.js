import React from 'react';
import {
  Row, Col, Form, Button,
} from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import CancelButton from '../../layout/CancelButton';
import hyacinthApi from '../../../util/hyacinth_api';

class FieldSetForm extends React.Component {
  state = {
    fieldSet: {
      displayLabel: '',
    },
  }

  componentDidMount() {
    const { projectStringKey, id } = this.props.match.params

    if (id) {
      hyacinthApi.get(`/projects/${projectStringKey}/field_sets/${id}`)
        .then((res) => {
          const { fieldSet } = res.data

          this.setState(produce((draft) => {
            draft.fieldSet = fieldSet;
          }));
        })
        .catch((error) => {
          console.log(error);
        });
    }
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    this.props.submitFormAction(this.state.fieldSet);
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { projectStringKey, id } = this.props.match.params

    hyacinthApi.delete(`/projects/${projectStringKey}/field_sets/${id}`)
      .then((res) => {
        this.props.history.push(`/projects/${projectStringKey}/field_sets`);
      });
  }

  onChangeHandler = (event) => {
    const { target } = event;
    this.setState(produce((draft) => { draft.fieldSet[target.name] = target.value; }));
  }

  render() {
    let deleteButton = '';

    if (this.props.match.params.id) {
      deleteButton = <Button variant="outline-danger" type="button" onClick={this.onDeleteHandler}>Delete</Button>;
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
                onChange={this.onChangeHandler}
              />
            </Col>
          </Form.Group>

          <Form.Row>
            <Col sm="auto" className="mr-auto">{deleteButton}</Col>

            <Col sm="auto">
              <CancelButton to={`/projects/${this.props.match.params.projectStringKey}/field_sets`} />
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

export default withRouter(FieldSetForm);
