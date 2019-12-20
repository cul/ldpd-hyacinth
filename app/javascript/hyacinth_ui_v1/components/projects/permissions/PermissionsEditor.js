import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import { Table, Form } from 'react-bootstrap';
import produce from 'immer';

import GraphQLErrors from '../../ui/GraphQLErrors';
import { getProjectPermissionsQuery, getProjectPermissionActionsQuery } from '../../../graphql/projects';

function PermissionsEditor(props) {
  const { projectStringKey } = props;
  const [permissionsChanged, setPermissionsChanged] = useState(false);
  const [projectPermissions, setProjectPermissions] = useState([]);

  const { loading: actionsLoading, error: actionsError, data: actionsData } = useQuery(
    getProjectPermissionActionsQuery, { variables: { stringKey: projectStringKey } },
  );
  const { loading: permissionsLoading, error: permissionsError } = useQuery(
    getProjectPermissionsQuery, {
      variables: { stringKey: projectStringKey },
      onCompleted: (data) => {
        setProjectPermissions(data.projectPermissionsForProject);
      },
    },
  );

  if (actionsLoading || permissionsLoading) return (<></>);
  if (actionsError || permissionsError) {
    return (<GraphQLErrors errors={actionsError || permissionsError} />);
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

  const renderProjectPermission = (projectPermission, actions) => {
    return actions.map(action => (
      <td key={action}>
        <Form.Check
          disabled={props.readonly}
          type="checkbox"
          checked={projectPermission.permissions.includes(action)}
          onChange={(e) => {
            updatePermissionsData(projectPermission.user.id, action, e.target.checked);
          }}
        />
      </td>
    ));
  };

  const renderProjectPermissions = (projectPerms, actions) => {
    return projectPerms.map(projectPermission => (
      <tr key={projectPermission.user}>
        <td key="name">
          {projectPermission.user.fullName}
        </td>
        {renderProjectPermission(projectPermission, actions)}
      </tr>
    ));
  };

  return (
    <>
      <Table striped bordered hover size="sm">
        <thead>
          <tr>
            <th key="name">Name</th>
            { actionsData.projectPermissionActions.map(action => (<th key={action}>{actionToDisplayLabel(action)}</th>)) }
          </tr>
        </thead>
        <tbody>
          {renderProjectPermissions(projectPermissions, actionsData.projectPermissionActions)}
        </tbody>
      </Table>
    </>
  );
}

PermissionsEditor.propTypes = {
  readonly: PropTypes.bool,
  projectStringKey: PropTypes.string.isRequired,
};

PermissionsEditor.defaultProps = {
  readonly: false,
};

export default PermissionsEditor;
