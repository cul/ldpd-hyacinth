import React, { useState } from 'react';
import { Spinner, Button, Form, Alert } from 'react-bootstrap';
import { useUserProjects } from '../api/get-user-projects';
import { useUpdateUserProjectPermissions } from '../api/update-user-projects';
import { ProjectPermission } from '@/types/api';
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  createColumnHelper,
} from '@tanstack/react-table';
import { Table as BTable } from 'react-bootstrap';

declare module '@tanstack/react-table' {
  interface TableMeta<TData> {
    updateData: (rowIndex: number, columnId: string, value: boolean) => void;
  }
}

const columnHelper = createColumnHelper<ProjectPermission>();

// WIP: Following editable table example: https://tanstack.com/table/latest/docs/framework/react/examples/editable-data
export const UserProjectPermissionsForm = ({ userUid }: { userUid: string }) => {
  const userPermissionsQuery = useUserProjects({ userUid });
  const [data, setData] = useState<ProjectPermission[]>([]);
  const [hasChanges, setHasChanges] = useState(false);

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

  const columns = [
    columnHelper.accessor('projectDisplayLabel', {
      header: 'Project',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('canRead', {
      header: 'Can Read',
      cell: (info) => {
        const value = info.getValue();
        const updateData = info.table.options.meta?.updateData;

        return (
          <Form.Check
            type="checkbox"
            checked={value}
            onChange={(e) => {
              updateData?.(info.row.index, info.column.id, e.target.checked);
            }}
          />
        );
      },
    }),
    columnHelper.accessor('canUpdate', {
      header: 'Can Update',
      cell: (info) => {
        const value = info.getValue();
        const updateData = info.table.options.meta?.updateData;

        return (
          <Form.Check
            type="checkbox"
            checked={value}
            onChange={(e) => {
              updateData?.(info.row.index, info.column.id, e.target.checked);
            }}
          />
        );
      },
    }),
    columnHelper.accessor('canCreate', {
      header: 'Can Create',
      cell: (info) => {
        const value = info.getValue();
        const updateData = info.table.options.meta?.updateData;

        return (
          <Form.Check
            type="checkbox"
            checked={value}
            onChange={(e) => {
              updateData?.(info.row.index, info.column.id, e.target.checked);
            }}
          />
        );
      },
    }),
    columnHelper.accessor('canPublish', {
      header: 'Can Publish',
      cell: (info) => {
        const value = info.getValue();
        const updateData = info.table.options.meta?.updateData;

        return (
          <Form.Check
            type="checkbox"
            checked={value}
            onChange={(e) => {
              updateData?.(info.row.index, info.column.id, e.target.checked);
            }}
          />
        );
      },
    }),
    columnHelper.accessor('isProjectAdmin', {
      header: 'Is Project Admin',
      cell: (info) => {
        const value = info.getValue();
        const updateData = info.table.options.meta?.updateData;

        return (
          <Form.Check
            type="checkbox"
            checked={value}
            onChange={(e) => {
              updateData?.(info.row.index, info.column.id, e.target.checked);
            }}
          />
        );
      },
    }),
  ];

  const table = useReactTable({
    data,
    columns,
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
    },
  });


  const handleSave = () => {
    console.log('Saving data:', data);
    updatePermissionsMutation.mutate({
      userUid,
      projectPermissions: data,
    });
  };

  if (userPermissionsQuery.isLoading) {
    return <Spinner />;
  }

  const addNewRow = () => {
    const newRow: any = {
      project_string_key: 'new_project',
      can_read: false,
      can_update: false,
    };
    setData((old) => [...old, newRow]);
  }

  return (
    <div>
      <BTable striped bordered hover responsive size="md">
        <thead>
          {table.getHeaderGroups().map((headerGroup) => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <th key={header.id}>
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                      header.column.columnDef.header,
                      header.getContext()
                    )}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map((row) => (
            <tr key={row.id}>
              {row.getVisibleCells().map((cell) => (
                <td key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
        {/* TODO: Allow user to add new project permissions */}
        {/* <button onClick={addNewRow}>Add row</button> */}
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