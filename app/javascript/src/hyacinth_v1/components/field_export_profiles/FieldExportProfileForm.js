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

  const saveSuccessHandler = (result) => {
    if (result.data.createFieldExportProfile) {
      const { fieldExportProfile: { id: newId } } = result.data.createFieldExportProfile;
      history.push(`/field_export_profiles/${newId}/edit`);
    }
  };
  const deleteSuccessHandler = () => {
    history.push('/field_export_profiles');
  };

  const onSaveHandler = () => {
    const variables = { input: { name, translationLogic } };

    switch (formType) {
      case 'new':
        return createFieldExportProfile({ variables });
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
    return deleteFieldExportProfile({ variables });
  };
  const cancelTo = '/field_export_profiles';

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
        cancelTo={cancelTo}
        onDelete={onDeleteHandler}
        onDeleteSuccess={deleteSuccessHandler}
        onSave={onSaveHandler}
        onSaveSuccess={saveSuccessHandler}
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
