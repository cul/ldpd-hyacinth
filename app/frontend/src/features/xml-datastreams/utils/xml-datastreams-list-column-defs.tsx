import { Link } from 'react-router'
import { createColumnHelper } from '@tanstack/react-table'
import { XmlDatastream } from '@/types/api'

const columnHelper = createColumnHelper<XmlDatastream>()

export const columnDefs = [
  columnHelper.accessor('displayLabel', {
    header: 'Name',
    cell: ({ row }) => (
      <Link
        to={{ pathname: `/xml-datastreams/${row.original.stringKey}/edit` }}
        className="link-underline link-underline-opacity-0 link-underline-opacity-75-hover"
      >
        <span>{row.original.displayLabel}</span>
      </Link>
    )
  }),
  columnHelper.accessor('stringKey', {
    header: 'String Key',
    cell: (info) => info.getValue(),
  })
]
