import { Link } from 'react-router';
import { createColumnHelper } from '@tanstack/react-table';
import { formatLocalDateTime } from '@/utils/format';
import { ExportJob } from '@/types/api';
import { getCsvExportDownloadUrl } from '@/features/export-jobs/api/download-csv-export';
import { Button } from 'react-bootstrap';

const columnHelper = createColumnHelper<ExportJob>();

export const columnDefs = [
  columnHelper.accessor('id', {
    header: 'Export Job ID',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('searchParams', {
    header: 'Search Params',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('user.fullName', {
    header: 'Submitted By',
    cell: (info) => info.getValue() || 'Unknown',
  }),
  columnHelper.accessor('createdAt', {
    header: 'Submitted At',
    cell: (info) => formatLocalDateTime(info.getValue() || '') || 'Unknown',
  }),
  // TODO: In parenthesis show the duration
  columnHelper.accessor('status', {
    header: 'Status',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('numberOfRecordsProcessed', {
    header: 'Number of Records Processed',
    cell: (info) => info.getValue(),
  }),
  // The column below depends on if the job was successful or not
  columnHelper.display({
    id: 'download',
    header: 'Download',
    enableSorting: false,
    cell: ({ row }) => {
      const job = row.original;

      return (
        <Button as="a" href={getCsvExportDownloadUrl(job.id)} variant="link" className="p-0">
          Download
        </Button>
      );
    },
  }),
  // columnHelper.display({
  //   id: 'delete',
  //   header: 'Delete',
  //   enableSorting: false,
  //   cell: ({ row, table }) => {
  //     const job = row.original;
  //     const onDelete = () => table.options.meta?.onDeleteRow?.(job);

  //     return renderDeleteButton(job, currentUser, onDelete);
  //   },
  // }),
];
