import { useMemo } from 'react';
import { Spinner, Button, Alert } from 'react-bootstrap';

// Hooks and components
import { useProjects } from '@/features/projects/api/get-projects';
import { useUsers } from '../api/get-users';
import { CopyOtherPermissionsDisplay } from './copy-other-user-permissions-display';
import { useProjectPermissionsForm } from '../hooks/use-project-permissions-form';
import { MutationAlerts } from './mutation-alerts';
import { ProjectPermissionsTable } from './project-permissions-table';

/*
This component uses TanStack table to render and manage user project permissions
We already have a non-editable TableBuilder component, but since this form requires editable cells 
and custom actions, we implement the table logic directly here
*/
export const UserProjectPermissionsForm = ({ userUid }: { userUid: string }) => {
  const projectsQuery = useProjects();
  const usersQuery = useUsers();

  const {
    data,
    addPermission,
    updatePermission,
    removePermission,
    hasChanges,
    handleSave,
    isError,
    isLoading,
    error,
    mutation,
    // Copy permissions state
    selectedUserUid,
    setSelectedUserUid,
    mergePermissions,
  } = useProjectPermissionsForm({ userUid });

  // Calculate unassigned projects client-side
  const unassignedProjects = useMemo(() => {
    if (!projectsQuery.data?.projects) return [];

    const assignedProjectIds = new Set(data.map(p => p.projectId));
    return projectsQuery.data.projects.filter(
      project => !assignedProjectIds.has(project.id)
    );
  }, [projectsQuery.data, data]);

  const nonAdminUsers = useMemo(() => {
    return usersQuery.data?.users?.filter(user => !user.isAdmin && user.uid !== userUid) || [];
  }, [usersQuery.data?.users, userUid]);

  // Loading states
  if (isLoading || projectsQuery.isLoading) {
    return <Spinner animation="border" />;
  }

  // Error states
  if (isError) {
    return (
      <Alert variant="danger">
        Error loading permissions: {error?.message}
      </Alert>
    );
  }

  if (projectsQuery.isError) {
    return (
      <Alert variant="danger">
        Error loading projects: {projectsQuery.error?.message}
      </Alert>
    );
  }

  return (
    <div>
      <MutationAlerts
        mutation={mutation}
        successMessage="Permissions saved successfully!"
        errorMessage="Error saving permissions"
      />

      <CopyOtherPermissionsDisplay
        onSelectUser={(uid: string) => setSelectedUserUid(uid)}
        selectedUserUid={selectedUserUid}
        usersList={nonAdminUsers}
        mergeUserPermissions={mergePermissions}
      />

      <ProjectPermissionsTable
        data={data}
        unassignedProjects={unassignedProjects}
        onUpdatePermission={updatePermission}
        onRemovePermission={removePermission}
        onAddPermission={addPermission}
      />

      {/* Save button should remain above the fold, in case we have a long list of projects */}
      <div className="d-flex align-items-center sticky-bottom gap-2 py-3 bg-white">
        <Button
          variant="primary"
          onClick={handleSave}
          disabled={!hasChanges || mutation.isPending}
        >
          {mutation.isPending ? 'Saving...' : 'Save Changes'}
        </Button>

        {hasChanges && (
          <small className="text-muted">You have unsaved changes</small>
        )}
      </div>
    </div>
  );
};