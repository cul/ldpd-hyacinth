import React from 'react'
import { flexRender, Row, Cell } from '@tanstack/react-table'

interface TableRowProps<T> {
  row: Row<T>
}

const TableRow = <T extends object>({ row }: TableRowProps<T>) => {
  return (
    <tr key={row.id} style={{ verticalAlign: 'middle' }}>
      {row.getVisibleCells().map((cell: Cell<T, unknown>) => (
        <td key={cell.id}>
          {flexRender(cell.column.columnDef.cell, cell.getContext())}
        </td>
      ))}
    </tr>
  )
}

export default TableRow;