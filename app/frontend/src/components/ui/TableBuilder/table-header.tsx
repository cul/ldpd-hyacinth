import React from 'react'
import { flexRender, HeaderGroup } from '@tanstack/react-table'

interface TableHeaderProps<T> {
  headerGroup: HeaderGroup<T>
}

function TableHeader<T>({ headerGroup }: TableHeaderProps<T>) {
  return (
    <thead>
      <tr key={headerGroup.id}>
        {headerGroup.headers.map((header) => (
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