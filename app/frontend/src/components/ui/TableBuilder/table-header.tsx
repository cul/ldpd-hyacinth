import React from 'react'
import { flexRender, HeaderGroup } from '@tanstack/react-table'

interface TableHeaderProps<T> {
  headerGroup: HeaderGroup<T>
}

function TableHeader<T>({ headerGroup }: TableHeaderProps<T>) {
  const renderSortingIcon = (sortDirection: 'asc' | 'desc' | null) => {
    // const iconMapping = {
      //   asc: 'fa-arrow-up',
      //   desc: 'fa-arrow-down',
      //   inactive: 'fa-arrow-down-up inactive',
      // }
      
    // TODO: Change to use FontAwesome icons after we change how FontAwesome is imported
    // (from using Ruby gem to using npm package)
    const iconMapping = {
      asc: '\u2191',
      desc: '\u2193',
      inactive: '\u2195',
    }

    const iconClass = sortDirection ? iconMapping[sortDirection] : iconMapping['inactive']
    const isInactive = !sortDirection

    // return <i className={`fa-solid ${iconClass} ms-1`} />
    return <span className={`ms-2 ${isInactive ? 'text-muted' : ''}`}>{iconClass}</span>
  }

  const createColumnHeader = (header: any) => {
    const columnData = header.column

    return (
      <button
        className="btn btn-sort d-flex justify-content-between m-0 p-0 align-items-center"
        onClick={columnData.getToggleSortingHandler()}
      >
        {!header.isPlaceholder &&
          flexRender(columnData.columnDef.header, header.getContext())}
        {columnData.getCanSort() && renderSortingIcon(columnData.getIsSorted())}
      </button>
    )
  }

  return (
    <thead>
      <tr key={headerGroup.id}>
        {headerGroup.headers.map((header) => (
          <th key={header.id}>
            {createColumnHeader(header)}
          </th>
        ))}
      </tr>
    </thead>
  )
}

export default TableHeader;