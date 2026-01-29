import { useState } from 'react';
import { Table as BTable } from 'react-bootstrap';
import { useReactTable, getCoreRowModel, getSortedRowModel, SortingState } from '@tanstack/react-table';
import { editableColumnDefs } from '../utils/project-permissions-column-defs';
import AddProjectPermissionRow from './AddProjectPermissionRow';
import TableHeader from '@/components/ui/table-builder/TableHeader';
import TableRow from '@/components/ui/table-builder/TableRow';
import { Project, ProjectPermission } from '@/types/api';

declare module '@tanstack/react-table' {
  interface TableMeta {
    updateData: (rowIndex: number, columnId: string, value: boolean) => void;
    removeRow: (rowIndex: number) => void;
  }
}

interface PermissionsTableProps {
  data: ProjectPermission[];
  unassignedProjects: Project[];
  onUpdatePermission: (rowIndex: number, columnId: string, value: boolean) => void;
  onRemovePermission: (rowIndex: number) => void;
  onAddPermission: (permission: ProjectPermission) => void;
}

// Editable TanStack Table for managing user project permissions
export default function ProjectPermissionsTable({
  data,
  unassignedProjects,
  onUpdatePermission,
  onRemovePermission,
  onAddPermission,
}: PermissionsTableProps) {
  const [sorting, setSorting] = useState<SortingState>([])

  const table = useReactTable({
    data,
    columns: editableColumnDefs,
    getCoreRowModel: getCoreRowModel(),
    meta: {
      updateData: onUpdatePermission,
      removeRow: onRemovePermission,
    },
    state: {
      sorting,
    },
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: setSorting,
  });

  return (
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
          onAddProject={onAddPermission}
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
  );
}