import React from 'react'
import { flexRender } from '@tanstack/react-table'

const TableRow = ({ row }: any) => {
  return (
    <tr key={row.id}>
      {row.getVisibleCells().map((cell: any) => (
        <td key={cell.id}>
          {flexRender(cell.column.columnDef.cell, cell.getContext())}
        </td>
      ))}
    </tr>
  )
}

export default TableRow;