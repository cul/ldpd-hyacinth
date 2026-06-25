import { createColumnHelper } from '@tanstack/react-table';
import { DigitalObjectImportSummary } from '@/types/api';

const columnHelper = createColumnHelper<DigitalObjectImportSummary>();

export const columnDefs = [
  columnHelper.accessor('id', {
    header: 'Id',
    cell: (info) => info.getValue(), // TODO: add link to digital object import details page
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
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('updatedAt', {
    header: 'Updated At',
    cell: (info) => info.getValue(),
  }),
];
