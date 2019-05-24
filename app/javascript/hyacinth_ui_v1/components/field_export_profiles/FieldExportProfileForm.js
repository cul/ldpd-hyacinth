import React from 'react';
import { Row, Col, Form } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';
import brace from 'brace';
import AceEditor from 'react-ace';
import 'brace/mode/json';
import 'brace/theme/textmate';

import SubmitButton from '../layout/forms/SubmitButton';
import DeleteButton from '../layout/forms/DeleteButton';
import CancelButton from '../layout/forms/CancelButton';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';

class FieldExportProfileForm extends React.Component {
  state = {
    formType: '',
    fieldExportProfile: {
      name: '',
      translationLogic: '{}',
    },
  }

  componentDidMount() {
    const { formType, id } = this.props;

    if (id) {
      hyacinthApi.get(`/field_export_profiles/${id}`)
        .then((res) => {
          const { fieldExportProfile } = res.data;

          this.setState(produce((draft) => {
            draft.fieldExportProfile = fieldExportProfile;
          }));
        });
    }

    this.setState(produce((draft) => {
      draft.formType = formType;
    }));
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { formType, fieldExportProfile: { id }, fieldExportProfile } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        hyacinthApi.post('/field_export_profiles', { fieldExportProfile })
          .then((res) => {
            const { fieldExportProfile: { id: newId } } = res.data;

            push(`/field_export_profiles/${newId}/edit`);
          });
        break;
      case 'edit':
        hyacinthApi.patch(`/field_export_profiles/${id}`, { fieldExportProfile })
          .then(() => push('/field_export_profiles'));
        break;
      default:
        break;
    }
  }

  onDeleteHandler = (event) => {
    event.preventDefault();

    const { fieldExportProfile: { id } } = this.state;

    hyacinthApi.delete(`/field_export_profiles/${id}`)
      .then(() => {
        this.props.history.push('/field_export_profiles');
      });
  }

  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    this.setState(produce((draft) => { draft.fieldExportProfile[name] = value; }));
  }

  onTranslationLogicChange = (value) => {
    this.setState(produce((draft) => {
      draft.fieldExportProfile.translationLogic = value;
    }));
  }

  render() {
    const { formType, fieldExportProfile: { name, translationLogic } } = this.state;

    return (
      <Form onSubmit={this.onSubmitHandler}>
        <Form.Group as={Row}>
          <Form.Label column sm={2}>Name</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="text"
              name="name"
              value={name}
              onChange={this.onChangeHandler}
            />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Translation Logic</Form.Label>
          <Col sm={10}>
            <AceEditor
              mode="json"
              theme="textmate"
              width="inherit"
              onChange={this.onTranslationLogicChange}
              value={translationLogic}
              name="translationLogic"
              editorProps={{ $blockScrolling: true }}
              tabSize={2}
            />
          </Col>
        </Form.Group>

        <Form.Row>
          <Col sm="auto" className="mr-auto">
            <DeleteButton formType={formType} onClick={this.onDeleteHandler} />
          </Col>

          <Col sm="auto">
            <CancelButton to="/field_export_profiles" />
          </Col>

          <Col sm="auto">
            <SubmitButton formType={formType} onClick={this.onSubmitHandler} />
          </Col>
        </Form.Row>
      </Form>
    );
  }
}

export default withRouter(withErrorHandler(FieldExportProfileForm, hyacinthApi));
