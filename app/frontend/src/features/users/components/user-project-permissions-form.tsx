import React, { useState } from 'react';
import { Spinner, Button, Form } from 'react-bootstrap';
import { useUserProjects } from '../api/get-user-projects';
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

  React.useEffect(() => {
    if (userPermissionsQuery.data) {
      setData(userPermissionsQuery.data);
    }
  }, [userPermissionsQuery.data]);

  const columns = [
    columnHelper.accessor('project_string_key', {
      header: 'Project',
      cell: (info) => info.getValue(),
    }),
    columnHelper.accessor('can_read', {
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
    columnHelper.accessor('can_update', {
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
      },
    },
  });

  // TODO: Send data to API
  const handleSave = () => {
    console.log('Saving data:', data);
  };

  if (userPermissionsQuery.isLoading) {
    return <Spinner />;
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
      </BTable>

      <Button variant="primary" onClick={handleSave}>
        Save Changes
      </Button>
    </div>
  );
};