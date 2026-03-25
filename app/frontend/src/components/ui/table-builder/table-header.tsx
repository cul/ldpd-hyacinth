import { flexRender, Header, HeaderGroup } from '@tanstack/react-table'
import { ArrowUp, ArrowDown, ArrowDownUp } from 'react-bootstrap-icons'

interface TableHeaderProps<T> {
  headerGroup: HeaderGroup<T>
}

function TableHeader<T>({ headerGroup }: TableHeaderProps<T>) {
  const renderSortingIcon = (sortDirection: 'asc' | 'desc' | null) => {
    const sharedClassNames = 'ms-2 flex-shrink-0 mt-1'

    if (sortDirection === 'asc') {
      return <ArrowUp className={sharedClassNames} size={14} />
    }
    if (sortDirection === 'desc') {
      return <ArrowDown className={sharedClassNames} size={14} />
    }
    return <ArrowDownUp className={sharedClassNames} style={{ color: '#b5b5b5ff' }} size={14} />
  }

  const createColumnHeader = (header: Header<T, unknown>) => {
    if (header.isPlaceholder) return null

    const sharedClassNames = 'fw-semibold d-inline-flex m-0 p-0 align-items-start text-start'
    const headerText = flexRender(header.column.columnDef.header, header.getContext())

    if (header.column.getCanSort()) {
      return (
        <button
          className={`btn ${sharedClassNames}`}
          onClick={header.column.getToggleSortingHandler()}
        >
          {headerText}
          {renderSortingIcon(header.column.getIsSorted() || null)}
        </button>
      )
    }

    return <div className={sharedClassNames}>{headerText}</div>
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