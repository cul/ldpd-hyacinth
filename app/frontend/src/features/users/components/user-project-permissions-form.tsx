import React, { useState, useMemo, useRef } from 'react';
import { Spinner, Button, Alert, Table as BTable } from 'react-bootstrap';
import { useReactTable, getCoreRowModel } from '@tanstack/react-table';

// Hooks and components
import TableHeader from '@/components/ui/TableBuilder/table-header';
import TableRow from '@/components/ui/TableBuilder/table-row';
import { useProjects } from '@/features/projects/api/get-projects';
import { useUsers } from '../api/get-users';
import { useUserProjects } from '../api/get-user-projects';
import { useUpdateUserProjectPermissions } from '../api/update-user-projects';
import { ProjectPermission } from '@/types/api';
import { editableColumnDefs } from './project-permissions-column-defs';
import { CopyOtherPermissionsDisplay } from './copy-other-user-permissions-display';
import { arePermissionArraysEqual } from '../utils/permissions';
import { AddProjectPermissionRow } from './add-project-permission-row';

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
  const userPermissionsQuery = useUserProjects({ userUid });
  const projectsQuery = useProjects();
  const usersQuery = useUsers();

  const [data, setData] = useState<ProjectPermission[]>([]);
  const [selectedUserUid, setSelectedUserUid] = useState<string>('');

  // Keep track of original data to compare for changes
  const originalDataRef = useRef<ProjectPermission[]>([]);

  // Fetch selected user's permissions only when a user is selected
  const selectedUserPermissionsQuery = useUserProjects({
    userUid: selectedUserUid,
    queryConfig: {
      enabled: !!selectedUserUid,
    }
  });

  // TODO: Extract form logic into a custom hook
  const updatePermissionsMutation = useUpdateUserProjectPermissions({
    mutationConfig: {
      onSuccess: () => {
        originalDataRef.current = data;
      },
    },
  });

  React.useEffect(() => {
    if (userPermissionsQuery.data) {
      setData(userPermissionsQuery.data);
      originalDataRef.current = userPermissionsQuery.data;
    }
  }, [userPermissionsQuery.data]);

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
        setData((old) =>
          old.map((row, index) => {
            if (index === rowIndex) {
              return {
                ...row,
                [columnId]: value,
              };
            }
            return row;
          })
        );
      },
      removeRow: (rowIndex: number) => {
        setData((old) => old.filter((_, index) => index !== rowIndex));
      }
    },
  });

  const hasChanges = useMemo(() => {
    return !arePermissionArraysEqual(data, originalDataRef.current);
  }, [data]);

  const handleSave = () => {
    updatePermissionsMutation.mutate({
      userUid,
      projectPermissions: data,
    });
  };

  const mergeUserPermissions = () => {
    if (!selectedUserUid || !selectedUserPermissionsQuery.data) return;

    const selectedPermissions = selectedUserPermissionsQuery.data;

    // Merge permissions: add new projects, preserve existing ones
    const mergedData = [...data];
    selectedPermissions.forEach(permission => {
      const existingIndex = mergedData.findIndex(p => p.projectId === permission.projectId);
      if (existingIndex === -1) {
        mergedData.push(permission);
      }
    });

    setData(mergedData);
    setSelectedUserUid('');
  };

  const handleAddProject = (newPermission: ProjectPermission) => {
    setData((old) => [...old, newPermission]);
  };

  if (userPermissionsQuery.isLoading || projectsQuery.isLoading) {
    return <Spinner animation="border" />;
  }

  if (userPermissionsQuery.isError) {
    return (
      <Alert variant="danger">
        Error loading permissions: {userPermissionsQuery.error?.message}
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
      {updatePermissionsMutation.isError && (
        <Alert variant="danger" dismissible onClose={() => updatePermissionsMutation.reset()}>
          Error saving permissions: {updatePermissionsMutation.error?.message}
        </Alert>
      )}

      {updatePermissionsMutation.isSuccess && (
        <Alert variant="success" dismissible onClose={() => updatePermissionsMutation.reset()}>
          Permissions saved successfully!
        </Alert>
      )}

      <CopyOtherPermissionsDisplay
        onSelectUser={(uid: string) => setSelectedUserUid(uid)}
        selectedUserUid={selectedUserUid}
        usersList={nonAdminUsers}
        mergeUserPermissions={mergeUserPermissions}
      />

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
            onAddProject={(newPermission) => handleAddProject(newPermission)}
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
          disabled={!hasChanges || updatePermissionsMutation.isPending}
        >
          {updatePermissionsMutation.isPending ? 'Saving...' : 'Save Changes'}
        </Button>

        {hasChanges && (
          <small className="text-muted">You have unsaved changes</small>
        )}
      </div>
    </div>
  );
};