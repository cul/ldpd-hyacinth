import React, { useState } from 'react';
import { Form } from 'react-bootstrap';
import { gql } from 'apollo-boost';
import { useMutation } from '@apollo/react-hooks';

import Checkbox from '../ui/forms/inputs/Checkbox';
import InputGroup from '../ui/forms/InputGroup';
import FormButtons from '../ui/forms/FormButtons';
import GraphQLErrors from '../ui/GraphQLErrors';
import { Can } from '../../util/ability_context';

const UPDATE_USER = gql`
  mutation UpdateUser($input: UpdateUserInput!){
    updateUser(input: $input){
      user {
        id
      }
    }
  }
`;

function SystemWidePermissionsForm(props) {
  const { id, isAdmin: initialIsAdmin, systemWidePermissions: initialSystemWidePermissions } = props;

  const [isAdmin, setIsAdmin] = useState(initialIsAdmin);
  const [manageVocabularies, setManageVocabularies] = useState(initialSystemWidePermissions.includes('manage_vocabularies'));
  const [manageUsers, setManageUsers] = useState(initialSystemWidePermissions.includes('manage_users'))
  const [readAllDigitalObjects, setReadAllDigitalObjects] = useState(initialSystemWidePermissions.includes('read_all_digital_objects'))
  const [manageAllDigitalObjects, setManageAllDigitalObjects] = useState(initialSystemWidePermissions.includes('manage_all_digital_objects'))

  const [updateUser, { error }] = useMutation(UPDATE_USER);

  const onSave = () => {
    const permissions = [];

    if (manageUsers) permissions.push('manage_users');
    if (manageVocabularies) permissions.push('manage_vocabularies');
    if (readAllDigitalObjects) permissions.push('read_all_digital_objects');
    if (manageAllDigitalObjects) permissions.push('manage_all_digital_objects');

    return updateUser({
      variables: {
        input: {
          id,
          isAdmin,
          permissions,
        },
      },
    }).then((res) => {
      // history.push(`/users/${res.data.updateUser.user.id}/edit`);
    });
  };

  return (
    <Form>
      <h5>System Wide Permissions</h5>

      <GraphQLErrors errors={error} />

      <InputGroup>
        <Can I="manage" a="all">
          <Checkbox
            sm={12}
            value={isAdmin}
            label="Administrator"
            onChange={v => setIsAdmin(v)}
            helpText="has ability to perform all actions"
          />
        </Can>
        <Checkbox
          sm={12}
          md={6}
          value={manageVocabularies}
          label="Manage Vocabularies"
          onChange={v => setManageVocabularies(v)}
          helpText="has ability to create/edit/delete vocabularies, and create/edit/delete terms"
        />
        <Checkbox
          md={6}
          sm={12}
          value={manageUsers}
          label="Manage Users"
          onChange={v => setManageUsers(v)}
          helpText="has ability to add new users, deactivate users, and add all system-wide permissions except administrator"
        />
        <Checkbox
          md={6}
          sm={12}
          value={readAllDigitalObjects}
          label="Read All Digital Objects"
          onChange={v => setReadAllDigitalObjects(v)}
          helpText="has ability to view all projects and all digital objects"
        />
        <Checkbox
          md={6}
          sn={12}
          value={manageAllDigitalObjects}
          onChange={v => setManageAllDigitalObjects(v)}
          label="Manage All Digital Objects"
          helpText="has ability to read/create/edit/delete all digital objects and view all projects"
        />
      </InputGroup>

      <FormButtons onSave={onSave} />
    </Form>
  );
}

export default SystemWidePermissionsForm;
