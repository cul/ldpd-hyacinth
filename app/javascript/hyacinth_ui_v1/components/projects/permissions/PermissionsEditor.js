import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import { Button, Form, Table } from 'react-bootstrap';
import produce from 'immer';
import Select from 'react-select'

import GraphQLErrors from '../../ui/GraphQLErrors';
import { getProjectPermissionsQuery, getProjectPermissionActionsQuery } from '../../../graphql/projects';
import { getUsersQuery } from '../../../graphql/users';

function PermissionsEditor(props) {
  let currentSelectUserSelection = null;
  const { readOnly } = props;

  const { projectStringKey } = props;
  const [permissionsChanged, setPermissionsChanged] = useState(false);
  const [projectPermissions, setProjectPermissions] = useState([]);

  const { loading: actionsLoading, error: actionsError, data: actionsData } = useQuery(
    getProjectPermissionActionsQuery, { variables: { stringKey: projectStringKey } },
  );
  const { loading: usersLoading, error: usersError, data: usersData } = useQuery(
    getUsersQuery,
  );
  const { loading: permissionsLoading, error: permissionsError } = useQuery(
    getProjectPermissionsQuery, {
      variables: { stringKey: projectStringKey },
      onCompleted: (data) => {
        setProjectPermissions(data.projectPermissionsForProject);
      },
    },
  );

  if (actionsLoading || permissionsLoading || usersLoading) return (<></>);
  if (actionsError || permissionsError || usersError) {
    return (<GraphQLErrors errors={actionsError || permissionsError || usersError} />);
  }

  const actionToDisplayLabel = (action) => {
    return action.split('_').map(part => part.charAt(0).toUpperCase() + part.slice(1)).join(' ');
  };

  const updatePermissionsData = (userId, action, enabled) => {
    setPermissionsChanged(true);
    setProjectPermissions(
      produce(projectPermissions, (draft) => {
        const { permissions } = draft.find(projectPermission => projectPermission.user.id === userId);
        if (enabled) {
          permissions.push(action); // add
        } else {
          permissions.splice(permissions.indexOf(action), 1); // remove
        }
      }),
    );
  };

  const renderProjectPermission = (projectPermission) => {
    return actionsData.projectPermissionActions.map(action => (
      <td key={action}>
        <Form.Check
          disabled={readOnly}
          type="checkbox"
          checked={projectPermission.permissions.includes(action)}
          onChange={(e) => {
            if (readOnly) return;
            updatePermissionsData(projectPermission.user.id, action, e.target.checked);
          }}
        />
      </td>
    ));
  };

  const renderProjectPermissions = () => {
    return projectPermissions.map(projectPermission => (
      <tr key={projectPermission.user.id}>
        <td key="name">
          {projectPermission.user.fullName}
        </td>

        {renderProjectPermission(projectPermission)}

        { !readOnly && (
          <td key="remove" className="text-center">
            <Button size="sm" variant="danger">Remove</Button>
          </td>
        ) }
      </tr>
    ));
  };

  const addSelectedUser = () => {
    if (currentSelectUserSelection == null) return;

    setProjectPermissions(
      produce(projectPermissions, (draft) => {
        draft.push({
          user: currentSelectUserSelection,
          project: {
            stringKey: projectStringKey,
          },
          permissions: ['read_objects'],
        });
      }),
    );
  };

  const renderUserAdd = () => {
    const addedUserIds = projectPermissions.map(permission => permission.user.id);
    const nonAddedUsers = usersData.users.filter(user => !addedUserIds.includes(user.id));
    return (
      <tr key="user-add">
        <td colSpan={actionsData.projectPermissionActions.length + 1}>
          <Select
            options={nonAddedUsers.map(user => ({ value: user.id, label: user.fullName }))}
            onChange={(val) => {currentSelectUserSelection = { id: val.value, fullName: val.label }; }}
          />
        </td>
        <td className="text-center align-middle">
          <Button size="sm" variant="primary" onClick={addSelectedUser}>Add</Button>
        </td>
      </tr>
    );
  };

  return (
    <>
      <Table striped bordered hover size="sm">
        <thead>
          <tr>
            <th key="name">Name</th>
            {actionsData.projectPermissionActions.map(
              action => (<th key={action}>{actionToDisplayLabel(action)}</th>)
            )}
            { !readOnly && (<th key="remove" className="text-center">Actions</th>) }
          </tr>
        </thead>
        <tbody>
          {renderProjectPermissions()}
          { !readOnly && renderUserAdd() }
        </tbody>
      </Table>
    </>
  );
}

PermissionsEditor.propTypes = {
  readOnly: PropTypes.bool,
  projectStringKey: PropTypes.string.isRequired,
};

PermissionsEditor.defaultProps = {
  readOnly: false,
};

export default PermissionsEditor;
