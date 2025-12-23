import * as React from 'react'

import {
  createColumnHelper,
  getCoreRowModel,
  useReactTable,
} from '@tanstack/react-table'

import TableHeader from './table-header'
import TableRow from './table-row'

import { User } from '../../../types/api'
import users from '../../../app/routes/app/users'

// temporary type
const columnHelper = createColumnHelper<User>()

const columns = [
  columnHelper.accessor('uid', {
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor((row) => row.first_name, {
    id: 'firstName',
    cell: (info) => <i>{info.getValue()}</i>,
    header: () => <span>Last Name</span>,
  }),
  // columnHelper.accessor('age', {
  //   header: () => 'Age',
  //   cell: (info) => info.renderValue(),
  //   footer: (info) => info.column.id,
  // }),
  // columnHelper.accessor('visits', {
  //   header: () => <span>Visits</span>,
  //   footer: (info) => info.column.id,
  // }),
  // columnHelper.accessor('status', {
  //   header: 'Status',
  //   footer: (info) => info.column.id,
  // }),
  // columnHelper.accessor('progress', {
  //   header: 'Profile Progress',
  //   footer: (info) => info.column.id,
  // }),
]

function TableBuilder({ data }: any) {
  console.log('TableBuilder users:', users);

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <div className="p-2">
      <table>
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
      </table>
    </div>
  )
}

export default TableBuilder;