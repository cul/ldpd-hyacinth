import * as React from 'react'

import {
  getCoreRowModel,
  useReactTable,
  ColumnDef
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
  const table = useReactTable<T>({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <BTable striped bordered hover responsive size="md">
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