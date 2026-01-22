import { useState } from 'react'

import {
  getCoreRowModel,
  useReactTable,
  ColumnDef,
  getSortedRowModel,
  SortingState
} from '@tanstack/react-table'
import { Table as BTable } from 'react-bootstrap'

import TableHeader from './table-header'
import TableRow from './table-row'

interface TableBuilderProps<T> {
  data: T[]
  columns: ColumnDef<T>[]
}

// This is a generic table component that can be reused across different data types
// When using this component, ensure you specify how to render each column in the column definitions
// Docs: https://tanstack.com/table/latest/docs/guide/column-defs
function TableBuilder<T extends object>({ data, columns }: TableBuilderProps<T>) {
  // You can disable sorting specific columns or specify custom sorting functions in the column definitions
  // Docs: https://tanstack.com/table/latest/docs/api/features/sorting#column-def-options
  const [sorting, setSorting] = useState<SortingState>([])

  const table = useReactTable<T>({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    state: {
      sorting,
    },
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: setSorting,
  })

  return (
    <BTable striped bordered hover responsive size="md" className="rounded-4">
      {table.getHeaderGroups().map((headerGroup) => (
        <TableHeader
          key={headerGroup.id}
          headerGroup={headerGroup} />
      ))}
      <tbody>
        {table.getRowModel().rows.map((row) => (
          <TableRow row={row} key={row.id} />
        ))}
      </tbody>
    </BTable>
  )
}

export default TableBuilder;