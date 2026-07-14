import { Button } from 'react-bootstrap';
import { createColumnHelper } from '@tanstack/react-table';
import { formatLocalDateTime } from '@/utils/format';
import { ExportJob } from '@/types/api';
import { getCsvExportDownloadUrl } from '../api/download-csv-export';

const columnHelper = createColumnHelper<ExportJob>();

export const columnDefs = [
  columnHelper.accessor('id', {
    header: 'Export ID',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('searchParams', {
    header: 'Search Params',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('user.fullName', {
    header: 'Exported By',
    cell: (info) => info.getValue() || 'Unknown',
  }),
  columnHelper.accessor('createdAt', {
    header: 'Submitted At',
    cell: (info) => formatLocalDateTime(info.getValue() || '') || 'Unknown',
  }),
  columnHelper.accessor('status', {
    header: 'Status',
    cell: (info) => {
      const status = info.getValue();
      const duration = info.row.original.duration;
      return duration != null ? `${status} (${duration} s)` : status;
    },
  }),
  columnHelper.accessor('numberOfRecordsProcessed', {
    header: 'Number of Records Processed',
    cell: (info) => info.getValue(),
  }),
  columnHelper.display({
    id: 'download',
    header: 'Download',
    enableSorting: false,
    cell: ({ row }) => {
      const job = row.original;
      const isSuccessful = job.status === 'success';

      if (isSuccessful) {
        return (
          <Button as="a" href={getCsvExportDownloadUrl(job.id)} variant="link" className="p-0">
            Download
          </Button>
        );
      }
      return <span className="text-muted">Pending</span>;
    },
  }),
  columnHelper.display({
    id: 'delete',
    header: 'Delete?',
    enableSorting: false,
    cell: ({ row, table }) => {
      const job = row.original;
      const onDelete = () => table.options.meta?.onDeleteRow?.(job);
      const isSuccessful = job.status === 'success';

      if (isSuccessful) {
        return (
          <Button variant="link" className="p-0 text-danger" onClick={onDelete}>
            Delete
          </Button>
        );
      }

      return <span className="text-muted">Pending</span>;
    },
  }),
];
