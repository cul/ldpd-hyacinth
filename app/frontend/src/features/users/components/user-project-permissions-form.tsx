import React, { useMemo } from 'react';
import { Spinner, Button, Alert, Table as BTable } from 'react-bootstrap';
import { useReactTable, getCoreRowModel } from '@tanstack/react-table';

// Hooks and components
import TableHeader from '@/components/ui/TableBuilder/table-header';
import TableRow from '@/components/ui/TableBuilder/table-row';
import { useProjects } from '@/features/projects/api/get-projects';
import { useUsers } from '../api/get-users';
import { editableColumnDefs } from './project-permissions-column-defs';
import { CopyOtherPermissionsDisplay } from './copy-other-user-permissions-display';
import { AddProjectPermissionRow } from './add-project-permission-row';
import { useProjectPermissionsForm } from '../hooks/use-project-permissions-form';

declare module '@tanstack/react-table' {
  interface TableMeta<TData> {
    updateData: (rowIndex: number, columnId: string, value: boolean) => void;
    removeRow: (rowIndex: number) => void;
  }
}

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
  }, [projectsQuery.data?.projects, data]);

  const nonAdminUsers = useMemo(() => {
    return usersQuery.data?.users?.filter(user => !user.isAdmin) || [];
  }, [usersQuery.data?.users]);

  const table = useReactTable({
    data,
    columns: editableColumnDefs,
    getCoreRowModel: getCoreRowModel(),
    meta: {
      updateData: (rowIndex: number, columnId: string, value: boolean) => {
        updatePermission(rowIndex, columnId, value);
      },
      removeRow: (rowIndex: number) => {
        removePermission(rowIndex);
      }
    },
  });

  if (isLoading || projectsQuery.isLoading) {
    return <Spinner animation="border" />;
  }

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
      {mutation.isError && (
        <Alert variant="danger" dismissible onClose={() => mutation.reset()}>
          Error saving permissions: {mutation.error?.message}
        </Alert>
      )}

      {mutation.isSuccess && (
        <Alert variant="success" dismissible onClose={() => mutation.reset()}>
          Permissions saved successfully!
        </Alert>
      )}

      <CopyOtherPermissionsDisplay
        onSelectUser={(uid: string) => setSelectedUserUid(uid)}
        selectedUserUid={selectedUserUid}
        usersList={nonAdminUsers}
        mergeUserPermissions={mergePermissions}
      />

      {/* TODO: Extract */}
      <BTable striped bordered hover responsive size="md" className="overflow-visible mt-3">
        <colgroup>
          <col style={{ width: '250px' }} />
          <col />
          <col />
          <col />
          <col />
          <col />
          <col />
          <col />
        </colgroup>
        {table.getHeaderGroups().map((headerGroup) => (
          <TableHeader
            key={headerGroup.id}
            headerGroup={headerGroup}
          />
        ))}
        <tbody>
          <AddProjectPermissionRow
            unassignedProjects={unassignedProjects}
            onAddProject={(newPermission) => addPermission(newPermission)}
          />
          {data.length === 0 && (
            <tr>
              <td colSpan={8} className="text-center text-muted py-4">
                No project permissions assigned.
              </td>
            </tr>
          )}
          {table.getRowModel().rows.map((row) => (
            <TableRow row={row} key={row.id} />
          ))}
        </tbody>
      </BTable>

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