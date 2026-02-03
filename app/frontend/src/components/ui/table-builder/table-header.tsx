import { flexRender, HeaderGroup } from '@tanstack/react-table'
import { ArrowUp, ArrowDown, ArrowDownUp } from 'react-bootstrap-icons'

interface TableHeaderProps<T> {
  headerGroup: HeaderGroup<T>
}

function TableHeader<T>({ headerGroup }: TableHeaderProps<T>) {
  const renderSortingIcon = (sortDirection: 'asc' | 'desc' | null) => {
    if (sortDirection === 'asc') {
      return <ArrowUp className="ms-2" size={14} />
    }
    if (sortDirection === 'desc') {
      return <ArrowDown className="ms-2" size={14} />
    }
    return <ArrowDownUp className="ms-2" style={{ color: '#b5b5b5ff' }} size={14} />
  }

  const createColumnHeader = (header: HeaderGroup<T>) => {
    if (header.isPlaceholder) return null

    const sharedClassNames = 'fw-semibold d-flex justify-content-between m-0 p-0 align-items-center'
    const headerText = flexRender(header.column.columnDef.header, header.getContext())

    if (header.column.getCanSort()) {
      return (
        <button
          className={`btn ${sharedClassNames}`}
          onClick={header.column.getToggleSortingHandler()}
        >
          {headerText}
          {renderSortingIcon(header.column.getIsSorted())}
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