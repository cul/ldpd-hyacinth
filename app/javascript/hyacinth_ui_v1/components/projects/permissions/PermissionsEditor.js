import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { Button, Form, Table } from 'react-bootstrap';
import produce from 'immer';
import Select from 'react-select';
import { remove as arrRemove, sortBy as collectionSortBy } from 'lodash';
import { useHistory } from 'react-router-dom';

import GraphQLErrors from '../../ui/GraphQLErrors';
import {
  getProjectPermissionActionsQuery, getProjectPermissionsQuery, updateProjectPermissionsMutation,
} from '../../../graphql/projects';
import { getUsersQuery } from '../../../graphql/users';
import AddButton from '../../ui/buttons/AddButton';
import RemoveButton from '../../ui/buttons/RemoveButton';
import CancelButton from '../../ui/forms/buttons/CancelButton';

function PermissionsEditor(props) {
  const { readOnly } = props;
  const { projectStringKey } = props;
  const history = useHistory();
  const [permissionsChanged, setPermissionsChanged] = useState(false);
  const [removedUserIds, setRemovedUserIds] = useState(new Set());
  const [allUsers, setAllUsers] = useState([]);
  const [projectPermissions, setProjectPermissions] = useState([]);
  const [currentAddUserSelection, setCurrentAddUserSelection] = useState(null);

  const { loading: actionsLoading, error: actionsError, data: actionsData } = useQuery(
    getProjectPermissionActionsQuery, { variables: { stringKey: projectStringKey } },
  );
  const { loading: usersLoading, error: usersError } = useQuery(
    getUsersQuery, {
      onCompleted: (data) => {
        setAllUsers(data.users);
      },
    },
  );
  const { loading: permissionsLoading, error: permissionsError } = useQuery(
    getProjectPermissionsQuery, {
      variables: { stringKey: projectStringKey },
      onCompleted: (data) => {
        setProjectPermissions(
          collectionSortBy(data.projectPermissionsForProject, [perm => perm.user.sortName])
        );
      },
    },
  );

  const [updateProjectPermissions, { error: updateProjectPermissionsError }] = useMutation(
    updateProjectPermissionsMutation,
  );

  if (actionsLoading || permissionsLoading || usersLoading) return (<></>);
  if (actionsError || permissionsError || usersError) {
    return (
      <GraphQLErrors errors={
        actionsError || permissionsError || usersError || updateProjectPermissionsError
      } />
    );
  }

  const actionToDisplayLabel = (action) => {
    return action.split('_').map(part => part.charAt(0).toUpperCase() + part.slice(1)).join(' ');
  };

  const updatePermissionsData = (userId, action, enabled) => {
    setPermissionsChanged(true);

    const { projectPermissionActions: {
      actions: allActions, manageAction, actionsDisallowedForAggregatorProjects },
    } = actionsData;

    setProjectPermissions(
      produce(projectPermissions, (draft) => {
        const { actions: currentActionsForUser, project } = draft.find(
          projectPermission => projectPermission.user.id === userId,
        );
        if (enabled) {
          if (action === manageAction) {
            // disable any current actions
            currentActionsForUser.splice(0, currentActionsForUser.length);
            // enable all allowed actions
            if (project.isPrimary) {
              currentActionsForUser.push(...allActions);
            } else {
              currentActionsForUser.push(...allActions.filter(
                act => !actionsDisallowedForAggregatorProjects.includes(act)
              ));
            }
          } else {
            // enable single action
            currentActionsForUser.push(action);
          }
        } else {
          // disable single action
          currentActionsForUser.splice(currentActionsForUser.indexOf(action), 1);
        }
      }),
    );
  };

  const removeUser = (userId) => {
    setPermissionsChanged(true);
    setProjectPermissions(
      produce(projectPermissions, (draft) => {
        arrRemove(draft, (projectPermission) => {
          return projectPermission.user.id === userId;
        });
      }),
    );
    setRemovedUserIds(
      produce(removedUserIds, (draft) => {
        draft.add(userId);
      }),
    );
  };

  const renderProjectPermission = (projectPermission) => {
    const {
      projectPermissionActions: {
        actions, readObjectsAction, actionsDisallowedForAggregatorProjects,
      },
    } = actionsData;

    return actions.map((action) => {
      const disabledCheckbox = readOnly || action === readObjectsAction || (
        !projectPermission.project.isPrimary
        && actionsDisallowedForAggregatorProjects.includes(action)
      );

      return (
        <td key={action}>
          { /* eslint-disable jsx-a11y/label-has-associated-control, jsx-a11y/label-has-for */ }
          { /* Note 1: ESLint is getting confused by label + react-bootstrap element. */ }
          { /* Note 2: We're Using a label for a wider clickable checkbox area. */ }
          <label
            id={`label-${projectPermission.user.id}-${action}`}
            htmlFor={`checkbox-${projectPermission.user.id}-${action}`}
            className="w-100"
            >
            <Form.Check
              id={`checkbox-${projectPermission.user.id}-${action}`}
              label="&nbsp;"
              disabled={disabledCheckbox}
              type="checkbox"
              checked={projectPermission.actions.includes(action)}
              onChange={(e) => {
                if (readOnly) return;
                updatePermissionsData(projectPermission.user.id, action, e.target.checked);
              }}
            />
          </label>
          { /* eslint-enable jsx-a11y/label-has-associated-control, jsx-a11y/label-has-for */ }
        </td>
      );
    });
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
            <RemoveButton onClick={() => {removeUser(projectPermission.user.id); }} />
          </td>
        ) }
      </tr>
    ));
  };

  const addSelectedUser = () => {
    if (currentAddUserSelection == null) return;
    setPermissionsChanged(true);

    const { projectPermissionActions: { readObjectsAction } } = actionsData;
    const userId = currentAddUserSelection.value;
    const user = allUsers.find(u => u.id === userId);

    setProjectPermissions(produce(projectPermissions, (draft) => {
      draft.push({
        user,
        project: {
          stringKey: projectStringKey,
        },
        actions: [readObjectsAction],
      });
    }));

    // If the added user was previously among the set of removedUserIds,
    // then remove the added user's id from removedUserIds.
    if (removedUserIds.has(userId)) {
      setRemovedUserIds(
        produce(removedUserIds, (draft) => {
          draft.delete(userId);
        }),
      );
    }

    setCurrentAddUserSelection(null); // this will clear out the current select item
  };

  const renderUserAdd = () => {
    const addedUserIds = projectPermissions.map(permission => permission.user.id);
    const nonAddedUsers = allUsers.filter(user => !addedUserIds.includes(user.id));
    return (
      <tr key="user-add">
        <td colSpan={actionsData.projectPermissionActions.actions.length + 1}>
          <Select
            placeholder="Add a user..."
            value={currentAddUserSelection}
            options={nonAddedUsers.map(user => ({ value: user.id, label: user.fullName }))}
            onChange={(val) => { setCurrentAddUserSelection(val); }}
          />
        </td>
        <td className="text-center align-middle">
          <AddButton onClick={addSelectedUser} />
        </td>
      </tr>
    );
  };

  const onSubmitHandler = (e) => {
    e.preventDefault();
    const variables = {
      input: {
        projectPermissionsUpdate: projectPermissions.map((projectPermission) => {
          return {
            projectStringKey: projectPermission.project.stringKey,
            userId: projectPermission.user.id,
            actions: projectPermission.actions,
          };
        }).concat(
          // We're also going to send projectPermission elements with an
          // empty permissions array for user removal.
          [...removedUserIds].map((userId) => {
            return {
              projectStringKey,
              userId,
              actions: [],
            };
          }),
        ),
      },
    };

    updateProjectPermissions({ variables }).then(() => {
      setPermissionsChanged(false);
      history.push(`/projects/${projectStringKey}/permissions/`);
    });
  };

  return (
    <form onSubmit={onSubmitHandler}>
      <Table striped bordered hover size="sm">
        <thead>
          <tr>
            <th key="name">Name</th>
            {actionsData.projectPermissionActions.actions.map(
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
      {
        !readOnly && (
          <div className="text-right">
            <CancelButton to={`/projects/${projectStringKey}/permissions`} />
            &nbsp;
            <Button variant="primary" onClick={onSubmitHandler} disabled={!permissionsChanged}>
              {permissionsChanged ? 'Save' : 'Saved'}
            </Button>
          </div>
        )
      }
    </form>
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
