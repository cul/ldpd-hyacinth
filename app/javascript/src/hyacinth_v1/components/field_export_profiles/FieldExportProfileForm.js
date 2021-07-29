import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';
import { useMutation } from '@apollo/react-hooks';

import FormButtons from '../shared/forms/FormButtons';
import JSONInput from '../shared/forms/inputs/JSONInput';
import TextInput from '../shared/forms/inputs/TextInput';
import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import {
  createFieldExportProfileMutation,
  updateFieldExportProfileMutation,
  deleteFieldExportProfileMutation,
} from '../../graphql/fieldExportProfiles';
import GraphQLErrors from '../shared/GraphQLErrors';

function FieldExportProfileForm(props) {
  const { formType, fieldExportProfile } = props;

  const [name, setName] = useState(fieldExportProfile ? fieldExportProfile.name : '');
  const [translationLogic, setTranslationLogic] = useState(fieldExportProfile ? fieldExportProfile.translationLogic : '{}');

  const history = useHistory();

  const [createFieldExportProfile, { error: createError }] = useMutation(
    createFieldExportProfileMutation,
  );
  const [updateFieldExportProfile, { error: updateError }] = useMutation(
    updateFieldExportProfileMutation,
  );
  const [deleteFieldExportProfile, { error: deleteError }] = useMutation(
    deleteFieldExportProfileMutation,
  );

  const onSave = () => {
    const variables = { input: { name, translationLogic } };

    switch (formType) {
      case 'new':
        return createFieldExportProfile({ variables }).then((res) => {
          const { fieldExportProfile: { id: newId } } = res.data.createFieldExportProfile;

          history.push(`/field_export_profiles/${newId}/edit`);
        });
      case 'edit':
        variables.input.id = fieldExportProfile.id;
        return updateFieldExportProfile({ variables });
      default:
        return null;
    }
  };

  const onDeleteHandler = (event) => {
    event.preventDefault();

    const variables = { input: { id: fieldExportProfile.id } };
    deleteFieldExportProfile({ variables }).then(() => {
      history.push('/field_export_profiles');
    });
  };

  return (
    <Form>
      <GraphQLErrors errors={createError || updateError || deleteError} />

      <InputGroup>
        <Label>Name</Label>
        <TextInput value={name} onChange={setName} />
      </InputGroup>

      <InputGroup>
        <Label>Translation Logic</Label>
        <JSONInput value={translationLogic} onChange={v => setTranslationLogic(v)} inputName="translationLogic" />
      </InputGroup>

      <FormButtons
        formType={formType}
        cancelTo="/field_export_profiles"
        onDelete={onDeleteHandler}
        onSave={onSave}
      />
    </Form>
  );
}

FieldExportProfileForm.defaultProps = {
  fieldExportProfile: null,
};

FieldExportProfileForm.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  fieldExportProfile: PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    translationLogic: PropTypes.string.isRequired,
  }),
};

export default FieldExportProfileForm;
