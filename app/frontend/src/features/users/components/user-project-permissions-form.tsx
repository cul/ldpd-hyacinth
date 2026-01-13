import React, { useState, useMemo } from 'react';
import { Spinner, Button, Form, Alert, Table as BTable } from 'react-bootstrap';
import { useReactTable, getCoreRowModel } from '@tanstack/react-table';

// Hooks and components
import TableRow from '@/components/ui/TableBuilder/table-row';
import { useProjects } from '@/features/projects/api/get-projects';
import { useUserProjects } from '../api/get-user-projects';
import { useUpdateUserProjectPermissions } from '../api/update-user-projects';
import { ProjectPermission } from '@/types/api';
import { columnDefs } from './project-permissions-column-defs';
import TableHeader from '@/components/ui/TableBuilder/table-header';

declare module '@tanstack/react-table' {
  interface TableMeta<TData> {
    updateData: (rowIndex: number, columnId: string, value: boolean) => void;
    removeRow: (rowIndex: number) => void;
  }
}

export const UserProjectPermissionsForm = ({ userUid }: { userUid: string }) => {
  const userPermissionsQuery = useUserProjects({ userUid });
  const projectsQuery = useProjects();

  const [data, setData] = useState<ProjectPermission[]>([]);
  const [hasChanges, setHasChanges] = useState(false);
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');

  const updatePermissionsMutation = useUpdateUserProjectPermissions({
    mutationConfig: {
      onSuccess: () => {
        setHasChanges(false);
      },
    },
  });

  React.useEffect(() => {
    if (userPermissionsQuery.data) {
      setData(userPermissionsQuery.data);
      setHasChanges(false);
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

  const table = useReactTable({
    data,
    columns: columnDefs,
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
        // TODO: Only set hasChanges to true if the new data is different from the original data
        setHasChanges(true);
      },
      removeRow: (rowIndex: number) => {
        setData((old) => old.filter((_, index) => index !== rowIndex));
        setHasChanges(true);
      }
    },
  });

  const handleSave = () => {
    updatePermissionsMutation.mutate({
      userUid,
      projectPermissions: data,
    });
  };

  const handleAddProject = () => {
    if (!selectedProjectId) return;

    const project = unassignedProjects.find((project) => project.id === parseInt(selectedProjectId));

    if (project) {
      const newPermission: ProjectPermission = {
        projectId: project.id,
        projectStringKey: project.stringKey,
        projectDisplayLabel: project.displayLabel,
        canRead: true,
        canCreate: false,
        canUpdate: false,
        canDelete: false,
        canPublish: false,
        isProjectAdmin: false,
      };

      setData((old) => [...old, newPermission]);
      setSelectedProjectId('');
      setHasChanges(true);
    }
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

      {/* TODO: Allow for copying different user's project permissions */}

      <BTable striped bordered hover responsive size="md">
        {table.getHeaderGroups().map((headerGroup) => (
          <TableHeader
            key={headerGroup.id}
            headerGroup={headerGroup}
          />
        ))}
        <tbody>
          {table.getRowModel().rows.map((row) => (
            <TableRow row={row} key={row.id} />
          ))}

          {/* TODO: This dropdown should allow searching/filtering but Bootstrap dropdowns don't support it out of the box */}
          {unassignedProjects.length > 0 && (
            <tr>
              <td>
                <Form.Select
                  size="sm"
                  value={selectedProjectId}
                  onChange={(e) => setSelectedProjectId(e.target.value)}
                >
                  <option value="">- Select a project -</option>
                  {unassignedProjects.map((project) => (
                    <option key={project.id} value={project.id}>
                      {project.displayLabel}
                    </option>
                  ))}
                </Form.Select>
              </td>
              <td colSpan={7}>
                <Button
                  size="sm"
                  variant="secondary"
                  onClick={handleAddProject}
                  disabled={!selectedProjectId}
                >
                  Add Project
                </Button>
              </td>
            </tr>
          )}
        </tbody>
      </BTable>

      <div className="d-flex gap-2 align-items-center">
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