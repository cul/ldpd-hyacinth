import { Link } from 'react-router'
import { createColumnHelper } from '@tanstack/react-table'
import { PublishTarget } from '@/types/api'

const columnHelper = createColumnHelper<PublishTarget>()

export const columnDefs = [
  columnHelper.accessor('displayLabel', {
    header: 'Name',
    cell: ({ row }) => (
      <Link
        to={{ pathname: `/publish-targets/${row.original.stringKey}/edit` }}
        className="link-underline link-underline-opacity-0"
      >
        <span className="hover:underline">{row.original.displayLabel}</span>
      </Link>
    )
  }),
  columnHelper.accessor('stringKey', {
    header: 'String Key',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('publishUrl', {
    header: 'Publish URL',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('projects', {
    header: 'Number of Projects Assigned',
    cell: (info) => info.getValue()?.length || 'No Projects Assigned',
  }),
]
