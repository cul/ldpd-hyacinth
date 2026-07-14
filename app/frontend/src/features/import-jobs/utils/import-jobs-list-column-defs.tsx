import { Link } from 'react-router';
import { createColumnHelper } from '@tanstack/react-table';
import { Button } from 'react-bootstrap';
import { ImportJobSummary } from '@/types/api';
import { formatLocalDateTime } from '@/utils/format';
import { User } from '@/types/api';

const columnHelper = createColumnHelper<ImportJobSummary>();

const renderDeleteButton = (
  row: ImportJobSummary,
  currentUser: User | undefined,
  onDeleteRow?: (row: ImportJobSummary) => void,
) => {
  const onDelete = () => onDeleteRow?.(row);

  if (row.complete) {
    return (
      <Button variant="outline-secondary" size="sm" onClick={onDelete}>
        Delete
      </Button>
    );
  }

  return (
    <div>
      Job not complete
      {currentUser?.isAdmin && (
        <>
          <br />
          <Button variant="outline-secondary" size="sm" onClick={onDelete}>
            Force delete
          </Button>
        </>
      )}
    </div>
  );
};

export const columnDefs = [
  columnHelper.accessor('id', {
    header: 'Import Job ID',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('name', {
    header: 'Name',
    cell: ({ row }) => (
      <Link
        to={{ pathname: `/import-jobs/${row.original.id}` }}
        className="link-underline link-underline-opacity-0 link-underline-opacity-75-hover"
      >
        <span>{row.original.name}</span>
      </Link>
    ),
  }),
  columnHelper.accessor('status', {
    header: 'Status',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('priority', {
    header: 'Priority',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('createdAt', {
    header: 'Submitted At',
    cell: (info) => formatLocalDateTime(info.getValue() || '') || 'Unknown',
  }),
  columnHelper.accessor('user.uid', {
    header: 'Submitted By',
    cell: (info) => info.getValue() || 'Unknown',
  }),
  columnHelper.display({
    id: 'actions',
    header: 'Actions',
    enableSorting: false,
    cell: ({ row, table }) => {
      const job = row.original;
      const currentUser = table.options.meta?.currentUser;
      const onDelete = () => table.options.meta?.onDeleteRow?.(job);

      return renderDeleteButton(job, currentUser, onDelete);
    },
  }),
];
