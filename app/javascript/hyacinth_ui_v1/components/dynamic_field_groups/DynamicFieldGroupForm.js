import React from 'react';
import {
  Row, Col, Form, Button, Breadcrumb, Card
} from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import { LinkContainer } from 'react-router-bootstrap';
import produce from 'immer';
import queryString from 'query-string';

import CancelButton from '../layout/CancelButton';
import hyacinthApi from '../../util/hyacinth_api';
import DynamicFieldsAndGroupsTable from '../layout/dynamic_fields/DynamicFieldsAndGroupsTable';

class DynamicFieldGroupForm extends React.Component {
  state = {
    formType: '',
    dynamicFieldCategories: [],
    dynamicFieldGroup: {
      stringKey: '',
      displayLabel: '',
      sortOrder: '',
      isRepeatable: false,
      parentType: '',
      parentId: ''
    },
    children: [],
  }

  componentDidMount() {
    const { match: { params: { id } }, location: { search } } = this.props

    if (id) {
      hyacinthApi.get(`/dynamic_field_groups/${id}`)
        .then((res) => {
          const { dynamicFieldGroup, dynamicFieldGroup: { parentType } } = res.data;

          if (parentType === 'DynamicFieldCategory') {
            this.loadCategories()
          }

          this.setState(produce((draft) => {
            draft.formType = 'edit';
            draft.dynamicFieldGroup = dynamicFieldGroup; // except children
            draft.children = dynamicFieldGroup.children
          }));
        });
    } else if (search) {
      const { parentType, parentId } = queryString.parse(search);

      if (parentType === 'DynamicFieldCategory') {
        this.loadCategories();
      }

      this.setState(produce((draft) => {
        draft.formType = 'new';
        draft.dynamicFieldGroup.parentType = parentType || 'DynamicFieldCategory';
        draft.dynamicFieldGroup.parentId = parentId;

      }));
    }
  }

  loadCategories() {
    hyacinthApi.get('/dynamic_field_categories')
      .then((res) => {
        this.setState(produce((draft) => {
          draft.dynamicFieldCategories = res.data.dynamicFieldCategories.map(category => ({ id: category.id, displayLabel: category.displayLabel }));
        }));
      });
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    this.props.submitFormAction(this.state.dynamicFieldGroup);
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { id } = this.props.match.params;

    hyacinthApi.delete(`/dynamic_field_groups/${id}`)
      .then((res) => {
        this.props.history.push('/dynamic_fields');
      });
  }

  onChangeHandler = (event) => {
    const { target: { type, name, value, checked } } = event;

    this.setState(produce((draft) => {
      draft.dynamicFieldGroup[name] = type === 'checkbox' ? checked : value;
    }));
  }

  render() {
    const {
      formType,
      dynamicFieldGroup: { stringKey, displayLabel, sortOrder, isRepeatable, parentType, parentId },
      dynamicFieldCategories
    } = this.state;

    let deleteButton = '';
    if (this.props.match.params.id) {
      deleteButton = <Button variant="outline-danger" type="button" onClick={this.onDeleteHandler}>Delete</Button>;
    }

    let categoriesDropdown = '';
    if (parentType === 'DynamicFieldCategory') {
      categoriesDropdown = (
        <Form.Group as={Row}>
          <Form.Label column sm={12} lg={3}>Dynamic Field Category</Form.Label>
          <Col sm={12} lg={9}>
            <Form.Control
              as="select"
              name="parentId"
              value={parentId}
              onChange={this.onChangeHandler}
            >
              {dynamicFieldCategories.map(c => (<option key={c.id} value={c.id}>{c.displayLabel}</option>)) }
            </Form.Control>
          </Col>
        </Form.Group>
      )
    }

    return (
      <>
        <Breadcrumb>
          <LinkContainer to="/dynamic_fields">
            <Breadcrumb.Item>Dynamic Fields</Breadcrumb.Item>
          </LinkContainer>
          <Breadcrumb.Item>
             something
          </Breadcrumb.Item>
          <Breadcrumb.Item active>{formType === 'new' ? 'New Dynamic Field Group' : displayLabel}</Breadcrumb.Item>
        </Breadcrumb>

        <Row>
          <Col sm={6}>
            <Form onSubmit={this.onSubmitHandler}>
              <Form.Group as={Row}>
                <Form.Label column sm={12} xl={3}>String Key</Form.Label>
                <Col sm={12} xl={9}>
                  <Form.Control
                    type="text"
                    name="stringKey"
                    value={stringKey}
                    onChange={this.onChangeHandler}
                  />
                </Col>
              </Form.Group>

              <Form.Group as={Row}>
                <Form.Label column sm={12} xl={3}>Display Label</Form.Label>
                <Col sm={12} xl={9}>
                  <Form.Control
                    type="text"
                    name="displayLabel"
                    value={displayLabel}
                    onChange={this.onChangeHandler}
                  />
                </Col>
              </Form.Group>

              <Form.Group as={Row}>
                <Form.Label column sm={12} xl={3}>Sort Order</Form.Label>
                <Col sm={12} xl={9}>
                  <Form.Control
                    type="number"
                    name="sortOrder"
                    value={sortOrder}
                    onChange={this.onChangeHandler}
                  />
                </Col>
              </Form.Group>

              {categoriesDropdown}

              <Form.Group as={Row}>
                <Form.Label column sm={12} xl={3}>Is Repeatable?</Form.Label>
                <Col sm={12} xl={9}>
                  <Form.Check
                    name="isRepeatable"
                    aria-label="is repeatable option"
                    checked={isRepeatable}
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
          </Col>
          <Col sm={6}>
            <Card>
              <Card.Header>Child Fields and Field Groups</Card.Header>
              <Card.Body>
                <DynamicFieldsAndGroupsTable rows={this.state.children} />

                <LinkContainer to={`/dynamic_fields/new?dynamic_field_group_id=${this.state.dynamicFieldGroup.id}`}>
                  <Button variant="primary">New Child Field</Button>
                </LinkContainer>

                <LinkContainer to={`/dynamic_field_groups/new?parentId=${this.state.dynamicFieldGroup.id}&parentType=DynamicFieldGroup`}>
                  <Button variant="primary">New Child Field Group</Button>
                </LinkContainer>
              </Card.Body>
            </Card>
          </Col>
        </Row>
      </>
    )
  }
}

export default withRouter(DynamicFieldGroupForm);
