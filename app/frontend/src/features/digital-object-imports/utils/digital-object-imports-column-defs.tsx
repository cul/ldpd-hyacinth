import { Link } from 'react-router';
import { createColumnHelper } from '@tanstack/react-table';
import { DigitalObjectImportSummary } from '@/types/api';
import { formatLocalDateTime } from '@/utils/format';

const columnHelper = createColumnHelper<DigitalObjectImportSummary>();

export const columnDefs = [
  columnHelper.accessor('id', {
    header: 'Id',
    cell: ({ row }) => (
      <Link
        to={{ pathname: `${row.original.id}` }}
        className="link-underline link-underline-opacity-0 link-underline-opacity-75-hover"
      >
        <span>{row.original.id}</span>
      </Link>
    ),
  }),
  columnHelper.accessor('csvRowNumber', {
    header: 'CSV Row Number',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('status', {
    header: 'Status',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('createdAt', {
    header: 'Created At',
    cell: (info) => formatLocalDateTime(info.getValue() || '') || 'Unknown',
  }),
  columnHelper.accessor('updatedAt', {
    header: 'Updated At',
    cell: (info) => formatLocalDateTime(info.getValue() || '') || 'Unknown',
  }),
];
