import React from 'react';
import {
  Row, Col, Form, Button, Breadcrumb
} from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import CancelButton from '../layout/CancelButton';
import hyacinthApi from '../../util/hyacinth_api';

class DynamicFieldCategoryForm extends React.Component {
  state = {
    dynamicFieldCategory: {
      displayLabel: '',
      sortOrder: '',
    },
  }

  componentDidMount() {
    const { id } = this.props.match.params;

    if (id) {
      hyacinthApi.get(`/dynamic_field_categories/${id}`)
        .then((res) => {
          const { dynamicFieldCategory } = res.data;

          this.setState(produce((draft) => {
            draft.dynamicFieldCategory = dynamicFieldCategory;
          }));
        });
    }
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    this.props.submitFormAction(this.state.dynamicFieldCategory);
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { id } = this.props.match.params;

    hyacinthApi.delete(`/dynamic_field_categories/${id}`)
      .then((res) => {
        this.props.history.push('/dynamic_fields');
      });
  }

  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    this.setState(produce((draft) => { draft.dynamicFieldCategory[name] = value; }));
  }

  render() {
    let deleteButton = '';

    if (this.props.match.params.id) {
      deleteButton = <Button variant="outline-danger" type="button" onClick={this.onDeleteHandler}>Delete</Button>;
    }

    const { dynamicFieldCategory: { displayLabel, sortOrder } } = this.state;

    return (
      <Form onSubmit={this.onSubmitHandler}>
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
          <Form.Label column sm={2}>Sort Order</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="number"
              name="sortOrder"
              value={sortOrder}
              onChange={this.onChangeHandler}
            />
          </Col>
        </Form.Group>

        <Form.Row>
          <Col sm="auto" className="mr-auto">{deleteButton}</Col>

          <Col sm="auto">
            <CancelButton to="/dynamic_fields" />
          </Col>

          <Col sm="auto">
            <Button variant="primary" type="submit" onClick={this.onSubmitHandler}>{this.props.submitButtonName}</Button>
          </Col>
        </Form.Row>
      </Form>
    )
  }
}

export default withRouter(DynamicFieldCategoryForm);
