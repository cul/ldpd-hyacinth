import React from 'react';
import { Row, Col, Form } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import CancelButton from '../../layout/forms/CancelButton';
import DeleteButton from '../../layout/forms/DeleteButton';
import SubmitButton from '../../layout/forms/SubmitButton';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';

class FieldSetForm extends React.Component {
  state = {
    formType: 'new',
    projectStringKey: '',
    fieldSet: {
      displayLabel: '',
    },
  }

  componentDidMount() {
    const { projectStringKey, id, formType } = this.props;

    if (id) {
      hyacinthApi.get(`/projects/${projectStringKey}/field_sets/${id}`)
        .then((res) => {
          const { fieldSet } = res.data;

          this.setState(produce((draft) => {
            draft.fieldSet = fieldSet;
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

    const { projectStringKey, formType, fieldSet, fieldSet: { id } } = this.state;

    switch (formType) {
      case 'new':
        hyacinthApi.post(`/projects/${projectStringKey}/field_sets`, fieldSet)
          .then((res) => {
            this.props.history.push(`/projects/${projectStringKey}/field_sets/${res.data.fieldSet.id}/edit`);
          });
        break;
      case 'edit':
        hyacinthApi.patch(`/projects/${projectStringKey}/field_sets/${id}`, fieldSet)
          .then((res) => {
            this.props.history.push(`/projects/${projectStringKey}/field_sets/`);
          });
        break;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { projectStringKey, fieldSet: { id } } = this.state;

    hyacinthApi.delete(`/projects/${projectStringKey}/field_sets/${id}`)
      .then((res) => {
        this.props.history.push(`/projects/${projectStringKey}/field_sets`);
      });
  }

  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    this.setState(produce((draft) => { draft.fieldSet[name] = value; }));
  }

  render() {
    const { formType, projectStringKey, fieldSet: { displayLabel } } = this.state;

    return (
      <div>
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

          <Form.Row>
            <Col sm="auto" className="mr-auto">
              <DeleteButton formType={formType} onClick={this.onDeleteHandler} />
            </Col>

            <Col sm="auto">
              <CancelButton to={`/projects/${projectStringKey}/field_sets`} />
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

export default withRouter(withErrorHandler(FieldSetForm, hyacinthApi));
