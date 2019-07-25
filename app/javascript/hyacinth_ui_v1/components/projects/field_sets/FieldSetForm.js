import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import FormButtons from '../../ui/forms/FormButtons';
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

  onSubmitHandler = () => {
    const {
      projectStringKey,
      formType,
      fieldSet,
      fieldSet: { id },
    } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        return hyacinthApi.post(`/projects/${projectStringKey}/field_sets`, fieldSet)
          .then((res) => {
            push(`/projects/${projectStringKey}/field_sets/${res.data.fieldSet.id}/edit`);
          });
      case 'edit':
        return hyacinthApi.patch(`/projects/${projectStringKey}/field_sets/${id}`, fieldSet)
          .then(() => push(`/projects/${projectStringKey}/field_sets/`));
      default:
        return null;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { projectStringKey, fieldSet: { id } } = this.state;
    const { history: { push } } = this.props;

    hyacinthApi.delete(`/projects/${projectStringKey}/field_sets/${id}`)
      .then(() => push(`/projects/${projectStringKey}/field_sets`));
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

          <FormButtons
            formType={formType}
            cancelTo={`/projects/${projectStringKey}/field_sets`}
            onDelete={this.onDeleteHandler}
            onSave={this.onSubmitHandler}
          />
        </Form>
      </div>
    );
  }
}

FieldSetForm.defaultProps = {
  id: null,
};

FieldSetForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  projectStringKey: PropTypes.string.isRequired,
  id: PropTypes.string,
};

export default withRouter(withErrorHandler(FieldSetForm, hyacinthApi));
