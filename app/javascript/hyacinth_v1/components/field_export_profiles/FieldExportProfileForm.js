import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';
import produce from 'immer';

import FormButtons from '../shared/forms/FormButtons';
import JSONInput from '../shared/forms/inputs/JSONInput';
import TextInput from '../shared/forms/inputs/TextInput';
import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import hyacinthApi from '../../utils/hyacinthApi';
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

  onSave = () => {
    const { formType, fieldExportProfile: { id }, fieldExportProfile } = this.state;
    const { history: { push } } = this.props;

    switch (formType) {
      case 'new':
        return hyacinthApi.post('/field_export_profiles', { fieldExportProfile })
          .then((res) => {
            const { fieldExportProfile: { id: newId } } = res.data;

            push(`/field_export_profiles/${newId}/edit`);
          });
      case 'edit':
        return hyacinthApi.patch(`/field_export_profiles/${id}`, { fieldExportProfile })
          .then((res) => {
            this.setState(produce((draft) => {
              draft.fieldExportProfile = res.data.fieldExportProfile;
            }));
          });
      default:
        return null;
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

  onChangeHandler(name, value) {
    this.setState(produce((draft) => {
      draft.fieldExportProfile[name] = value;
    }));
  }

  render() {
    const { formType, fieldExportProfile: { name, translationLogic } } = this.state;

    return (
      <Form onSubmit={this.onSubmitHandler}>
        <InputGroup>
          <Label>Name</Label>
          <TextInput
            value={name}
            onChange={v => this.onChangeHandler('name', v)}
          />
        </InputGroup>

        <InputGroup>
          <Label>Translation Logic</Label>
          <JSONInput
            onChange={v => this.onChangeHandler('translationLogic', v)}
            value={translationLogic}
            inputName="translationLogic"
          />
        </InputGroup>

        <FormButtons
          formType={formType}
          cancelTo="/field_export_profiles"
          onDelete={this.onDeleteHandler}
          onSave={this.onSave}
        />
      </Form>
    );
  }
}

FieldExportProfileForm.defaultProps = {
  id: null,
};

FieldExportProfileForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  id: PropTypes.string,
};

export default withRouter(withErrorHandler(FieldExportProfileForm, hyacinthApi));
