import { useState } from 'react';

import {
  getCoreRowModel,
  useReactTable,
  ColumnDef,
  getSortedRowModel,
  SortingState,
  PaginationState,
  OnChangeFn,
  TableMeta,
} from '@tanstack/react-table';
import { Table as BTable } from 'react-bootstrap';

import TableHeader from './table-header';
import TableRow from './table-row';
import TablePagination from './table-pagination';

interface TableBuilderProps<T> {
  data: T[];
  columns: ColumnDef<T>[];
  pagination?: ServerPagination;
  meta?: TableMeta<T>; // Used to pass additional data or functions
  size?: 'sm' | 'md';
}

interface ServerPagination {
  state: PaginationState;
  onPaginationChange: OnChangeFn<PaginationState>;
  rowCount: number;
}

// This is a generic table component that can be reused across different data types
// When using this component, ensure you specify how to render each column in the column definitions
// Docs: https://tanstack.com/table/latest/docs/guide/column-defs
function TableBuilder<T extends object>({
  data,
  columns,
  pagination,
  meta,
  size = 'md',
}: TableBuilderProps<T>) {
  // You can disable sorting specific columns or specify custom sorting functions in the column definitions
  // Docs: https://tanstack.com/table/latest/docs/api/features/sorting#column-def-options
  const [sorting, setSorting] = useState<SortingState>([]);

  const table = useReactTable<T>({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    state: {
      sorting,
      ...(pagination ? { pagination: pagination.state } : {}),
    },
    // Disable sorting when using server-side pagination; temporary workaround until we implement server-side sorting
    enableSorting: pagination ? false : true,
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: setSorting,
    meta,
    ...(pagination
      ? {
          manualPagination: true,
          rowCount: pagination.rowCount,
          onPaginationChange: pagination.onPaginationChange,
        }
      : {}),
  });

  return (
    <>
      {pagination && <TablePagination table={table} />}

      <BTable striped bordered hover responsive size={size} className="rounded-4">
        {table.getHeaderGroups().map((headerGroup) => (
          <TableHeader key={headerGroup.id} headerGroup={headerGroup} />
        ))}
        <tbody>
          {table.getRowModel().rows.length === 0 && (
            <tr>
              <td colSpan={columns.length} className="text-center py-3">
                No entries found.
              </td>
            </tr>
          )}
          {table.getRowModel().rows.map((row) => (
            <TableRow row={row} key={row.id} />
          ))}
        </tbody>
      </BTable>
    </>
  );
}

export default TableBuilder;
