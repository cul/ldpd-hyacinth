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

function TableBuilder<T extends object>({ data, columns }: TableBuilderProps<T>) {
  const table = useReactTable<T>({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <div className="p-2">
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
    </div>
  )
}

export default TableBuilder;