import React from 'react';
import { Row, Col, Form } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import SubmitButton from '../layout/forms/SubmitButton';
import DeleteButton from '../layout/forms/DeleteButton';
import CancelButton from '../layout/forms/CancelButton';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';

class DynamicFieldCategoryForm extends React.Component {
  state = {
    formType: '',
    dynamicFieldCategory: {
      displayLabel: '',
      sortOrder: '',
    },
  }

  componentDidMount() {
    const { formType, id } = this.props;

    if (id) {
      hyacinthApi.get(`/dynamic_field_categories/${id}`)
        .then((res) => {
          const { dynamicFieldCategory } = res.data;

          this.setState(produce((draft) => {
            draft.dynamicFieldCategory = dynamicFieldCategory;
          }));
        });
    }

    this.setState(produce((draft) => {
      draft.formType = formType;
    }));
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { formType, dynamicFieldCategory: { id }, dynamicFieldCategory } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        hyacinthApi.post('/dynamic_field_categories', dynamicFieldCategory)
          .then((res) => {
            const { dynamicFieldCategory: { id: newId } } = res.data;

            push(`/dynamic_field_categories/${newId}/edit`);
          });
        break;
      case 'edit':
        hyacinthApi.patch(`/dynamic_field_categories/${id}`, dynamicFieldCategory)
          .then(() => push('/dynamic_fields'));
        break;
      default:
        break;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { dynamicFieldCategory: { id } } = this.state;

    hyacinthApi.delete(`/dynamic_field_categories/${id}`)
      .then(() => {
        this.props.history.push('/dynamic_fields');
      });
  }

  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    this.setState(produce((draft) => { draft.dynamicFieldCategory[name] = value; }));
  }

  render() {
    const { formType, dynamicFieldCategory: { displayLabel, sortOrder } } = this.state;

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
          <Col sm="auto" className="mr-auto">
            <DeleteButton formType={formType} onClick={this.onDeleteHandler} />
          </Col>

          <Col sm="auto">
            <CancelButton to="/dynamic_fields" />
          </Col>

          <Col sm="auto">
            <SubmitButton formType={formType} onClick={this.onSubmitHandler} />
          </Col>
        </Form.Row>
      </Form>
    );
  }
}

export default withRouter(withErrorHandler(DynamicFieldCategoryForm, hyacinthApi));
