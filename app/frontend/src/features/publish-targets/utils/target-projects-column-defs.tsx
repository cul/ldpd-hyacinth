import { createColumnHelper } from '@tanstack/react-table';
import { Button } from 'react-bootstrap';
import { Project } from '@/types/api';

const columnHelper = createColumnHelper<Project>();

export const columnDefs = [
  columnHelper.accessor('displayLabel', {
    header: 'Project Label',
    cell: (info) => info.getValue(),
  }),
    columnHelper.accessor('stringKey', {
    header: 'Project String Key',
    cell: (info) => info.getValue(),
  }),
  columnHelper.display({
    id: 'actions',
    header: 'Actions',
    cell: (props) => (
      <Button
        variant="outline-secondary"
        size="sm"
        onClick={() => props.table.options.meta?.removeRow(props.row.index)}
      >
        Remove
      </Button>
    ),
    enableSorting: false,
  }),
];
