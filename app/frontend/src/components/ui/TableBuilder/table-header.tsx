import React from 'react'
import { flexRender } from '@tanstack/react-table'

const TableHeader = ({ headerGroup }: any) => {
  return (
    <thead>
      <tr key={headerGroup.id}>
        {headerGroup.headers.map((header: any) => (
          <th key={header.id}>
            {header.isPlaceholder
              ? null
              : flexRender(
                header.column.columnDef.header,
                header.getContext(),
              )}
          </th>
        ))}
      </tr>
    </thead>
  )
}

export default TableHeader;