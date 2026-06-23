import { Link } from 'react-router';
import { ImportJob } from '@/types/api';
import { createColumnHelper } from '@tanstack/react-table';
import Button from 'react-bootstrap/esm/Button';

const columnHelper = createColumnHelper<ImportJob>();

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
  columnHelper.accessor('createdAt', {
    header: 'Submitted At',
    cell: (info) => info.getValue() || 'Unknown',
  }),
  // columnHelper.accessor('createdBy', {
  //   header: 'Submitted By',
  //   cell: (info) => info.getValue() || 'Unknown',
  // }), // TODO: get the user who submitted the import job
  columnHelper.display({
    id: 'actions',
    header: 'Actions',
    cell: (props) => (
      <Button
        variant="outline-secondary"
        size="sm"
        // onClick={() => props.table.options.meta?.removeRow(props.row.index)} // TODO
      >
        Delete
      </Button>
    ),
    enableSorting: false,
  }),
];
